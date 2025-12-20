using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

public partial class Voxelization : Node
{
	public enum MeshingMode { Voxel, DualContouring }

	[Signal]
	public delegate void MeshReadyEventHandler(ArrayMesh mesh);

	public MeshingMode m_Mode = MeshingMode.Voxel;

	private struct EdgeData
	{
		public Vector3 m_IntersectionPoint;
		public Vector3 m_Normal;
	}

	private struct QEFData
	{
		public Vector3 m_ATA_Row0;
		public Vector3 m_ATA_Row1;
		public Vector3 m_ATA_Row2;
		public Vector3 m_ATb;
		public Vector3 m_MassPoint;
		public int m_EdgeCount;
	}

	private struct CellVertex
	{
		public Vector3 m_Position;
		public Vector3 m_Normal;
	}

	private float m_VoxelSize;
	private Vector3 m_Spacing;
	private float m_WorldSize;
	private int m_Threshold = 222;
	private volatile int m_ExpectedImages = 0;
	private volatile int m_ProcessedImages = 0;
	private int m_ImageWidth = 0;
	private int m_ImageHeight = 0;
	private ConcurrentQueue<(int index, byte[] data)> m_ProcessingQueue = new();
	private ConcurrentDictionary<Vector3I, EdgeData> m_EdgeData = new();
	private ConcurrentDictionary<Vector3I, QEFData> m_QEFData = new();
	private ConcurrentDictionary<Vector3I, CellVertex> m_CellVertices = new();
	private Dictionary<Vector3, int> m_VertexMap = new();
	private List<Vector3> m_Vertices = new();
	private List<Vector3> m_Normals = new();
	private List<int> m_Indices = new();
	private object m_MeshLock = new();
	private byte[] m_PrevSlice;
	private byte[] m_CurrentSlice;
	private byte[] m_NextSlice;

	public void StartCapture(int expected_images, float world_size = 2.5f)
	{
		m_ExpectedImages = expected_images;
		m_ProcessedImages = 0;
		m_WorldSize = world_size;
		m_ProcessingQueue.Clear();
		m_EdgeData.Clear();
		m_QEFData.Clear();
		m_CellVertices.Clear();
		m_VertexMap.Clear();
		m_Vertices.Clear();
		m_Normals.Clear();
		m_Indices.Clear();
		m_PrevSlice = null;
		m_CurrentSlice = null;
		m_NextSlice = null;
		if (m_Mode == MeshingMode.Voxel)
		{
			Task.Run(VoxelStreamingProcessor);
		}
		else
		{
			Task.Run(DualContouringStreamProcessor);
		}
	}

	public void AddImage(int index, Image image)
	{
		image.Convert(Image.Format.L8);
		if (m_ImageWidth == 0)
		{
			m_ImageWidth = image.GetWidth();
			m_ImageHeight = image.GetHeight();
			float max_dimension = Math.Max(Math.Max(m_ImageWidth, m_ImageHeight), m_ExpectedImages);
			m_VoxelSize = m_WorldSize / max_dimension;
			m_Spacing = new Vector3(m_VoxelSize, m_VoxelSize, m_VoxelSize);
		}
		byte[] raw_data = image.GetData();
		m_ProcessingQueue.Enqueue((index, raw_data));
		m_ProcessedImages++;
	}

	private async Task DualContouringStreamProcessor()
	{
		var stopwatch = System.Diagnostics.Stopwatch.StartNew();
		var sorted_slices = new SortedDictionary<int, byte[]>();
		int next_to_process = 0;
		while (next_to_process < m_ExpectedImages)
		{
			while (m_ProcessingQueue.TryDequeue(out var item))
			{
				sorted_slices[item.index] = item.data;
			}
			if (sorted_slices.ContainsKey(next_to_process))
			{
				byte[] current = sorted_slices[next_to_process];
				sorted_slices.Remove(next_to_process);
				byte[] next = sorted_slices.ContainsKey(next_to_process + 1) ? sorted_slices[next_to_process + 1] : null;
				m_CurrentSlice = current;
				m_NextSlice = next;
				DetectEdgeCrossings(next_to_process, m_PrevSlice, current, next);
				if (next_to_process > 0)
				{
					SolveVerticesForSlice(next_to_process - 1);
				}
				if (next_to_process > 1)
				{
					GenerateMeshForSlice(next_to_process - 2);
				}
				m_PrevSlice = current;
				next_to_process++;
				if (next_to_process % 50 == 0)
				{
					GD.Print($"did {next_to_process}/{m_ExpectedImages} slices");
				}
			}
			else
			{
				await Task.Delay(1);
			}
		}
		if (m_ExpectedImages > 0) SolveVerticesForSlice(m_ExpectedImages - 1);
		if (m_ExpectedImages > 1) GenerateMeshForSlice(m_ExpectedImages - 2);
		if (m_ExpectedImages > 0) GenerateMeshForSlice(m_ExpectedImages - 1);
		await GenerateFinalMesh();
		stopwatch.Stop();
		GD.Print($"dc mesh took {stopwatch.ElapsedMilliseconds}ms");
	}

	private async Task VoxelStreamingProcessor()
	{
		var stopwatch = System.Diagnostics.Stopwatch.StartNew();
		var sorted_slices = new SortedDictionary<int, byte[]>();
		int next_to_process = 0;
		GD.Print("voxel processor started");
		while (next_to_process < m_ExpectedImages)
		{
			while (m_ProcessingQueue.TryDequeue(out var item))
			{
				sorted_slices[item.index] = item.data;
			}
			if (sorted_slices.ContainsKey(next_to_process))
			{
				byte[] current = sorted_slices[next_to_process];
				sorted_slices.Remove(next_to_process);
				byte[] next = sorted_slices.ContainsKey(next_to_process + 1) ? sorted_slices[next_to_process + 1] : null;
				ProcessSlice(next_to_process, m_PrevSlice, current, next);
				m_PrevSlice = current;
				next_to_process++;
				if (next_to_process % 50 == 0)
				{
					GD.Print($"done {next_to_process}/{m_ExpectedImages} slices, verts: {m_Vertices.Count}, tris: {m_Indices.Count / 3}");
				}
			}
			else
			{
				await Task.Delay(1);
			}
		}
		GD.Print($"slices done, making mesh now");
		GD.Print($"got {m_Vertices.Count} verts, {m_Indices.Count} indices, {m_Normals.Count} normals");
		await GenerateFinalMesh();
		GD.Print("mesh ready");
		stopwatch.Stop();
		GD.Print($"total time: {stopwatch.ElapsedMilliseconds}ms");
	}

	private void ProcessSlice(int z, byte[] prev, byte[] current, byte[] next)
	{
		for (int y = 0; y < m_ImageHeight; y++)
		{
			for (int x = 0; x < m_ImageWidth; x++)
			{
				int index = y * m_ImageWidth + x;
				if (current[index] <= m_Threshold) continue;
				Vector3 pos = new Vector3(x * m_Spacing.X, y * m_Spacing.Y, z * m_Spacing.Z);
				AddCubeFacesWithCulling(pos, x, y, index, prev, current, next);
			}
		}
	}

	private void AddCubeFacesWithCulling(Vector3 pos, int x, int y, int index, byte[] prev, byte[] current, byte[] next)
	{
		lock (m_MeshLock)
		{
			if (!HasVoxel(prev, index))
			{
				int i0 = GetOrAddVertex(pos, Vector3.Zero);
				int i1 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z), Vector3.Zero);
				int i2 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z), Vector3.Zero);
				int i3 = GetOrAddVertex(new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z), Vector3.Zero);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
			if (!HasVoxel(next, index))
			{
				int i0 = GetOrAddVertex(new Vector3(pos.X, pos.Y, pos.Z + m_VoxelSize), Vector3.Zero);
				int i1 = GetOrAddVertex(new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize), Vector3.Zero);
				int i2 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize), Vector3.Zero);
				int i3 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z + m_VoxelSize), Vector3.Zero);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
			if (!HasVoxel(current, index - 1, x > 0))
			{
				int i0 = GetOrAddVertex(pos, Vector3.Zero);
				int i1 = GetOrAddVertex(new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z), Vector3.Zero);
				int i2 = GetOrAddVertex(new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize), Vector3.Zero);
				int i3 = GetOrAddVertex(new Vector3(pos.X, pos.Y, pos.Z + m_VoxelSize), Vector3.Zero);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
			if (!HasVoxel(current, index + 1, x < m_ImageWidth - 1))
			{
				int i0 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z), Vector3.Zero);
				int i1 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z + m_VoxelSize), Vector3.Zero);
				int i2 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize), Vector3.Zero);
				int i3 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z), Vector3.Zero);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
			if (!HasVoxel(current, index - m_ImageWidth, y > 0))
			{
				int i0 = GetOrAddVertex(pos, Vector3.Zero);
				int i1 = GetOrAddVertex(new Vector3(pos.X, pos.Y, pos.Z + m_VoxelSize), Vector3.Zero);
				int i2 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z + m_VoxelSize), Vector3.Zero);
				int i3 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z), Vector3.Zero);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
			if (!HasVoxel(current, index + m_ImageWidth, y < m_ImageHeight - 1))
			{
				int i0 = GetOrAddVertex(new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z), Vector3.Zero);
				int i1 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z), Vector3.Zero);
				int i2 = GetOrAddVertex(new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize), Vector3.Zero);
				int i3 = GetOrAddVertex(new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize), Vector3.Zero);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
		}
	}

	private void DetectEdgeCrossings(int z, byte[] prev, byte[] current, byte[] next)
	{
		for (int y = 0; y < m_ImageHeight; y++)
		{
			for (int x = 0; x < m_ImageWidth; x++)
			{
				int index = y * m_ImageWidth + x;
				byte centerValue = current[index];
				CheckAndAddEdge(x, y, z, centerValue, current, index + 1, x < m_ImageWidth - 1, 0);
				CheckAndAddEdge(x, y, z, centerValue, current, index + m_ImageWidth, y < m_ImageHeight - 1, 1);
				if (next != null)
				{
					CheckAndAddEdge(x, y, z, centerValue, next, index, true, 2);
				}
			}
		}
	}

	private void CheckAndAddEdge(int x, int y, int z, byte value1, byte[] slice, int idx2, bool inBounds, int axis)
	{
		if (!inBounds) return;
		byte value2 = slice[idx2];
		bool solid1 = value1 > m_Threshold;
		bool solid2 = value2 > m_Threshold;
		if (solid1 == solid2) return;
		Vector3 pos1 = new Vector3(x * m_Spacing.X, y * m_Spacing.Y, z * m_Spacing.Z);
		Vector3 pos2;
		if (axis == 0) pos2 = new Vector3((x + 1) * m_Spacing.X, y * m_Spacing.Y, z * m_Spacing.Z);
		else if (axis == 1) pos2 = new Vector3(x * m_Spacing.X, (y + 1) * m_Spacing.Y, z * m_Spacing.Z);
		else pos2 = new Vector3(x * m_Spacing.X, y * m_Spacing.Y, (z + 1) * m_Spacing.Z);
		Vector3 intersection = FindIntersection(pos1, pos2, value1, value2);
		Vector3 normal = EstimateNormal(intersection, x, y, z);
		Vector3I edgeKey = new Vector3I(x, y, z) * 2;
		if (axis == 0) edgeKey.X += 1;
		else if (axis == 1) edgeKey.Y += 1;
		else edgeKey.Z += 1;
		m_EdgeData[edgeKey] = new EdgeData { m_IntersectionPoint = intersection, m_Normal = normal };
		AccumulateEdgeToCell(x, y, z, intersection, normal);
		if (axis == 0 && x > 0) AccumulateEdgeToCell(x - 1, y, z, intersection, normal);
		if (axis == 1 && y > 0) AccumulateEdgeToCell(x, y - 1, z, intersection, normal);
		if (axis == 2 && z > 0) AccumulateEdgeToCell(x, y, z - 1, intersection, normal);
	}

	private Vector3 FindIntersection(Vector3 pos1, Vector3 pos2, byte value1, byte value2)
	{
		float t = (m_Threshold - value1) / (float)(value2 - value1);
		t = Mathf.Clamp(t, 0.0f, 1.0f);
		return pos1.Lerp(pos2, t);
	}

	private Vector3 EstimateNormal(Vector3 worldPos, int baseX, int baseY, int baseZ)
	{
		float epsilon = m_VoxelSize;
		float dx = SampleVoxelValue(worldPos.X + epsilon, worldPos.Y, worldPos.Z, baseX, baseY, baseZ) - SampleVoxelValue(worldPos.X - epsilon, worldPos.Y, worldPos.Z, baseX, baseY, baseZ);
		float dy = SampleVoxelValue(worldPos.X, worldPos.Y + epsilon, worldPos.Z, baseX, baseY, baseZ) - SampleVoxelValue(worldPos.X, worldPos.Y - epsilon, worldPos.Z, baseX, baseY, baseZ);
		float dz = SampleVoxelValue(worldPos.X, worldPos.Y, worldPos.Z + epsilon, baseX, baseY, baseZ) - SampleVoxelValue(worldPos.X, worldPos.Y, worldPos.Z - epsilon, baseX, baseY, baseZ);
		Vector3 gradient = new Vector3(dx, dy, dz);
		if (gradient.LengthSquared() > 0.0f) return gradient.Normalized();
		return Vector3.Up;
	}

	private float SampleVoxelValue(float wx, float wy, float wz, int baseX, int baseY, int baseZ)
	{
		int gx = Mathf.RoundToInt(wx / m_Spacing.X);
		int gy = Mathf.RoundToInt(wy / m_Spacing.Y);
		int gz = Mathf.RoundToInt(wz / m_Spacing.Z);
		if (gx < 0 || gx >= m_ImageWidth || gy < 0 || gy >= m_ImageHeight || gz < 0 || gz >= m_ExpectedImages) return 0.0f;
		int sliceOffset = gz - baseZ;
		if (sliceOffset == -1 && m_PrevSlice != null) return m_PrevSlice[gy * m_ImageWidth + gx];
		else if (sliceOffset == 0 && m_CurrentSlice != null) return m_CurrentSlice[gy * m_ImageWidth + gx];
		else if (sliceOffset == 1 && m_NextSlice != null) return m_NextSlice[gy * m_ImageWidth + gx];
		return 0.0f;
	}

	private void AccumulateEdgeToCell(int x, int y, int z, Vector3 intersection, Vector3 normal)
	{
		Vector3I cellKey = new Vector3I(x, y, z);
		m_QEFData.AddOrUpdate(cellKey,
			(key) => {
				QEFData qef = new QEFData();
				qef.m_ATA_Row0 = new Vector3(normal.X * normal.X, normal.X * normal.Y, normal.X * normal.Z);
				qef.m_ATA_Row1 = new Vector3(normal.Y * normal.X, normal.Y * normal.Y, normal.Y * normal.Z);
				qef.m_ATA_Row2 = new Vector3(normal.Z * normal.X, normal.Z * normal.Y, normal.Z * normal.Z);
				float dot = normal.Dot(intersection);
				qef.m_ATb = normal * dot;
				qef.m_MassPoint = intersection;
				qef.m_EdgeCount = 1;
				return qef;
			},
			(key, existingQef) => {
				existingQef.m_ATA_Row0 += new Vector3(normal.X * normal.X, normal.X * normal.Y, normal.X * normal.Z);
				existingQef.m_ATA_Row1 += new Vector3(normal.Y * normal.X, normal.Y * normal.Y, normal.Y * normal.Z);
				existingQef.m_ATA_Row2 += new Vector3(normal.Z * normal.X, normal.Z * normal.Y, normal.Z * normal.Z);
				float dot = normal.Dot(intersection);
				existingQef.m_ATb += normal * dot;
				existingQef.m_MassPoint += intersection;
				existingQef.m_EdgeCount++;
				return existingQef;
			});
	}

	private void SolveVerticesForSlice(int z)
	{
		for (int y = 0; y < m_ImageHeight; y++)
		{
			for (int x = 0; x < m_ImageWidth; x++)
			{
				Vector3I cellKey = new Vector3I(x, y, z);
				if (m_QEFData.TryGetValue(cellKey, out QEFData qef))
				{
					CellVertex vertex = SolveQEF(qef, x, y, z);
					m_CellVertices[cellKey] = vertex;
				}
			}
		}
	}

	private CellVertex SolveQEF(QEFData qef, int x, int y, int z)
	{
		if (qef.m_EdgeCount == 0)
		{
			Vector3 cellCenter = new Vector3((x + 0.5f) * m_VoxelSize, (y + 0.5f) * m_VoxelSize, (z + 0.5f) * m_VoxelSize);
			return new CellVertex { m_Position = cellCenter, m_Normal = Vector3.Up };
		}
		Vector3 massPoint = qef.m_MassPoint / qef.m_EdgeCount;
		Vector3 averageNormal = qef.m_ATb.Normalized();
		if (averageNormal.LengthSquared() < 0.01f) averageNormal = Vector3.Up;
		if (qef.m_EdgeCount < 3)
		{
			return new CellVertex { m_Position = massPoint, m_Normal = averageNormal };
		}
		float regularization = 0.001f;
		Vector3 ata0 = qef.m_ATA_Row0 + new Vector3(regularization, 0, 0);
		Vector3 ata1 = qef.m_ATA_Row1 + new Vector3(0, regularization, 0);
		Vector3 ata2 = qef.m_ATA_Row2 + new Vector3(0, 0, regularization);
		float det = ata0.X * (ata1.Y * ata2.Z - ata1.Z * ata2.Y) - ata0.Y * (ata1.X * ata2.Z - ata1.Z * ata2.X) + ata0.Z * (ata1.X * ata2.Y - ata1.Y * ata2.X);
		if (Mathf.Abs(det) < 0.00001f)
		{
			return new CellVertex { m_Position = massPoint, m_Normal = averageNormal };
		}
		float invDet = 1.0f / det;
		Vector3 inv0 = new Vector3(
			(ata1.Y * ata2.Z - ata1.Z * ata2.Y) * invDet,
			(ata0.Z * ata2.Y - ata0.Y * ata2.Z) * invDet,
			(ata0.Y * ata1.Z - ata0.Z * ata1.Y) * invDet
		);
		Vector3 inv1 = new Vector3(
			(ata1.Z * ata2.X - ata1.X * ata2.Z) * invDet,
			(ata0.X * ata2.Z - ata0.Z * ata2.X) * invDet,
			(ata0.Z * ata1.X - ata0.X * ata1.Z) * invDet
		);
		Vector3 inv2 = new Vector3(
			(ata1.X * ata2.Y - ata1.Y * ata2.X) * invDet,
			(ata0.Y * ata2.X - ata0.X * ata2.Y) * invDet,
			(ata0.X * ata1.Y - ata0.Y * ata1.X) * invDet
		);
		Vector3 solution = new Vector3(inv0.Dot(qef.m_ATb), inv1.Dot(qef.m_ATb), inv2.Dot(qef.m_ATb));
		Vector3 cellMin = new Vector3(x * m_VoxelSize, y * m_VoxelSize, z * m_VoxelSize);
		Vector3 cellMax = cellMin + new Vector3(m_VoxelSize, m_VoxelSize, m_VoxelSize);
		solution.X = Mathf.Clamp(solution.X, cellMin.X, cellMax.X);
		solution.Y = Mathf.Clamp(solution.Y, cellMin.Y, cellMax.Y);
		solution.Z = Mathf.Clamp(solution.Z, cellMin.Z, cellMax.Z);
		return new CellVertex { m_Position = solution, m_Normal = averageNormal };
	}

	private int GetOrAddVertex(Vector3 pos, Vector3 normal)
	{
		if (m_VertexMap.TryGetValue(pos, out int index))
		{
			return index;
		}
		index = m_Vertices.Count;
		m_Vertices.Add(pos);
		m_Normals.Add(normal);
		m_VertexMap[pos] = index;
		return index;
	}

	private void GenerateMeshForSlice(int z)
	{
		for (int y = 0; y < m_ImageHeight - 1; y++)
		{
			for (int x = 0; x < m_ImageWidth - 1; x++)
			{
				GenerateQuadsForCell(x, y, z);
			}
		}
	}

	private void GenerateQuadsForCell(int x, int y, int z)
	{
		Vector3I c000 = new Vector3I(x, y, z);
		GenerateQuadXY(c000);
		GenerateQuadXZ(c000);
		GenerateQuadYZ(c000);
	}

	private void GenerateQuadXY(Vector3I cell)
	{
		Vector3I c00 = cell;
		Vector3I c10 = cell + new Vector3I(1, 0, 0);
		Vector3I c11 = cell + new Vector3I(1, 1, 0);
		Vector3I c01 = cell + new Vector3I(0, 1, 0);
		if (m_CellVertices.ContainsKey(c00) && m_CellVertices.ContainsKey(c10) && m_CellVertices.ContainsKey(c11) && m_CellVertices.ContainsKey(c01))
		{
			lock (m_MeshLock)
			{
				int i0 = GetOrAddVertex(m_CellVertices[c00].m_Position, m_CellVertices[c00].m_Normal);
				int i1 = GetOrAddVertex(m_CellVertices[c10].m_Position, m_CellVertices[c10].m_Normal);
				int i2 = GetOrAddVertex(m_CellVertices[c11].m_Position, m_CellVertices[c11].m_Normal);
				int i3 = GetOrAddVertex(m_CellVertices[c01].m_Position, m_CellVertices[c01].m_Normal);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
		}
	}

	private void GenerateQuadXZ(Vector3I cell)
	{
		Vector3I c00 = cell;
		Vector3I c10 = cell + new Vector3I(1, 0, 0);
		Vector3I c11 = cell + new Vector3I(1, 0, 1);
		Vector3I c01 = cell + new Vector3I(0, 0, 1);
		if (m_CellVertices.ContainsKey(c00) && m_CellVertices.ContainsKey(c10) && m_CellVertices.ContainsKey(c11) && m_CellVertices.ContainsKey(c01))
		{
			lock (m_MeshLock)
			{
				int i0 = GetOrAddVertex(m_CellVertices[c00].m_Position, m_CellVertices[c00].m_Normal);
				int i1 = GetOrAddVertex(m_CellVertices[c10].m_Position, m_CellVertices[c10].m_Normal);
				int i2 = GetOrAddVertex(m_CellVertices[c11].m_Position, m_CellVertices[c11].m_Normal);
				int i3 = GetOrAddVertex(m_CellVertices[c01].m_Position, m_CellVertices[c01].m_Normal);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
		}
	}

	private void GenerateQuadYZ(Vector3I cell)
	{
		Vector3I c00 = cell;
		Vector3I c10 = cell + new Vector3I(0, 1, 0);
		Vector3I c11 = cell + new Vector3I(0, 1, 1);
		Vector3I c01 = cell + new Vector3I(0, 0, 1);
		if (m_CellVertices.ContainsKey(c00) && m_CellVertices.ContainsKey(c10) && m_CellVertices.ContainsKey(c11) && m_CellVertices.ContainsKey(c01))
		{
			lock (m_MeshLock)
			{
				int i0 = GetOrAddVertex(m_CellVertices[c00].m_Position, m_CellVertices[c00].m_Normal);
				int i1 = GetOrAddVertex(m_CellVertices[c10].m_Position, m_CellVertices[c10].m_Normal);
				int i2 = GetOrAddVertex(m_CellVertices[c11].m_Position, m_CellVertices[c11].m_Normal);
				int i3 = GetOrAddVertex(m_CellVertices[c01].m_Position, m_CellVertices[c01].m_Normal);
				m_Indices.Add(i0);
				m_Indices.Add(i1);
				m_Indices.Add(i2);
				m_Indices.Add(i0);
				m_Indices.Add(i2);
				m_Indices.Add(i3);
			}
		}
	}

	private bool HasVoxel(byte[] slice, int index, bool in_bounds = true)
	{
		if (slice == null || !in_bounds) return false;
		return slice[index] > m_Threshold;
	}

	private async Task GenerateFinalMesh()
	{
		await Task.Run(() => {
			GD.Print("making final mesh");
			if (m_Vertices.Count == 0)
			{
				GD.Print("no verts lol");
				CallDeferred(MethodName.EmitSignal, SignalName.MeshReady, (ArrayMesh)null);
				return;
			}
			GD.Print($"mesh has {m_Vertices.Count} verts and {m_Indices.Count / 3} tris");

			GD.Print("copying verts");
			var vertex_array = new Vector3[m_Vertices.Count];
			m_Vertices.CopyTo(vertex_array);
			m_Vertices.Clear();
			m_Vertices.TrimExcess();
			GD.Print("verts done");

			GD.Print("copying indices");
			var index_array = new int[m_Indices.Count];
			m_Indices.CopyTo(index_array);
			m_Indices.Clear();
			m_Indices.TrimExcess();
			GD.Print("indices done");

			m_VertexMap.Clear();
			GD.Print("cleared vertex map");

			Vector3[] normal_array;
			if (m_Mode == MeshingMode.Voxel)
			{
				GD.Print("calculating normals");
				normal_array = CalculateNormals(vertex_array, index_array);
				GD.Print("normals ready");
			}
			else
			{
				GD.Print("copying normals");
				normal_array = new Vector3[m_Normals.Count];
				m_Normals.CopyTo(normal_array);
				m_Normals.Clear();
				m_Normals.TrimExcess();
				GD.Print("normals done");
			}

			GD.Print("making array mesh");
			var array_mesh = new ArrayMesh();
			var arrays = new Godot.Collections.Array();
			arrays.Resize((int)Mesh.ArrayType.Max);
			arrays[(int)Mesh.ArrayType.Vertex] = vertex_array;
			arrays[(int)Mesh.ArrayType.Index] = index_array;
			arrays[(int)Mesh.ArrayType.Normal] = normal_array;

			GD.Print("adding surface");
			array_mesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, arrays);
			GD.Print("surface added");

			GD.Print("freeing arrays");
			vertex_array = null;
			index_array = null;
			normal_array = null;

			GD.Print("running gc");
			System.GC.Collect();
			GD.Print("gc done");

			GD.Print("emitting mesh");
			CallDeferred(MethodName.EmitSignal, SignalName.MeshReady, array_mesh);
			GD.Print("all done");
		});
	}

	public void VoxelizeFromBuffer()
	{
		if (m_ProcessedImages < m_ExpectedImages)
		{
			GD.PrintErr("not ready yet");
			CallDeferred(MethodName.EmitSignal, SignalName.MeshReady, (ArrayMesh)null);
		}
	}

	private Vector3[] CalculateNormals(Vector3[] vertices, int[] indices)
	{
		GD.Print($"allocating normals for {vertices.Length} verts");
		var normals = new Vector3[vertices.Length];

		GD.Print($"doing {indices.Length / 3} triangles");
		for (int i = 0; i < indices.Length; i += 3)
		{
			Vector3 v1 = vertices[indices[i]];
			Vector3 v2 = vertices[indices[i + 1]];
			Vector3 v3 = vertices[indices[i + 2]];
			Vector3 edge1 = v2 - v1;
			Vector3 edge2 = v3 - v1;
			Vector3 face_normal = edge2.Cross(edge1);
			if (face_normal.LengthSquared() > 0.0f)
			{
				face_normal = face_normal.Normalized();
				normals[indices[i]] = face_normal;
				normals[indices[i + 1]] = face_normal;
				normals[indices[i + 2]] = face_normal;
			}

			if (i > 0 && i % 1000000 == 0)
			{
				GD.Print($"progress: {i / 3} / {indices.Length / 3} tris");
			}
		}

		GD.Print("filling zero normals");
		for (int i = 0; i < normals.Length; i++)
		{
			if (normals[i].LengthSquared() == 0.0f)
			{
				normals[i] = Vector3.Up;
			}
		}

		GD.Print("normals calc done");
		return normals;
	}

	public void SaveMesh(ArrayMesh mesh, string file_path)
	{
		var arrays = mesh.SurfaceGetArrays(0);
		var vertices = (Vector3[])arrays[(int)Mesh.ArrayType.Vertex];
		var indices = (int[])arrays[(int)Mesh.ArrayType.Index];
		using var file = Godot.FileAccess.Open(file_path, Godot.FileAccess.ModeFlags.Write);
		if (file == null)
		{
			GD.PrintErr($"cant open file: {file_path}");
			return;
		}
		file.StoreLine("ply");
		file.StoreLine("format ascii 1.0");
		file.StoreLine($"element vertex {vertices.Length}");
		file.StoreLine("property float x");
		file.StoreLine("property float y");
		file.StoreLine("property float z");
		file.StoreLine($"element face {indices.Length / 3}");
		file.StoreLine("property list uchar int vertex_indices");
		file.StoreLine("end_header");
		foreach (var vertex in vertices)
		{
			file.StoreLine($"{vertex.X} {vertex.Y} {vertex.Z}");
		}
		for (int i = 0; i < indices.Length; i += 3)
		{
			file.StoreLine($"3 {indices[i]} {indices[i + 1]} {indices[i + 2]}");
		}
		GD.Print($"saved mesh to: {file_path}");
	}
}
