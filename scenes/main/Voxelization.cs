using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Godot;

public partial class Voxelization : Node
{
	[Signal]
	public delegate void MeshReadyEventHandler(ArrayMesh mesh);
	
	private readonly float m_VoxelSize = 2.5f / 450.0f;
	private readonly Vector3 m_Spacing = Vector3.One * (2.5f / 450.0f);
	private readonly int m_Threshold = 64;
	
	private volatile int m_ExpectedImages = 0;
	private volatile int m_ProcessedImages = 0;
	private volatile bool m_IsCapturing = false;
	private int m_ImageWidth = 0;
	private int m_ImageHeight = 0;
	
	private ConcurrentQueue<(int index, byte[] data)> m_ProcessingQueue = new();
	private byte[,,] m_VoxelData;
	private bool m_VoxelDataReady = false;
	
	public void StartCapture(int expected_images)
	{
		m_ExpectedImages = expected_images;
		m_ProcessedImages = 0;
		m_IsCapturing = true;
		m_VoxelDataReady = false;
		
		while (m_ProcessingQueue.TryDequeue(out _)) { }
		
		Task.Run(StreamingProcessor);
	}
	
	public void AddImage(int index, Image image)
	{
		if (!m_IsCapturing) return;
		
		image.Convert(Image.Format.L8);
		
		if (m_ImageWidth == 0)
		{
			m_ImageWidth = image.GetWidth();
			m_ImageHeight = image.GetHeight();
			m_VoxelData = new byte[m_ImageWidth, m_ImageHeight, m_ExpectedImages];
		}
		
		byte[] raw_data = image.GetData();
		m_ProcessingQueue.Enqueue((index, raw_data));
		m_ProcessedImages++;
	}
	
	private async Task StreamingProcessor()
	{
		var processed_indices = new HashSet<int>();
		
		while (processed_indices.Count < m_ExpectedImages)
		{
			if (m_ProcessingQueue.TryDequeue(out var item))
			{
				StoreLayerData(item.index, item.data);
				processed_indices.Add(item.index);
			}
			else
			{
				await Task.Delay(1);
			}
		}
		
		m_VoxelDataReady = true;
		await GenerateMeshWithCulling();
	}
	
	private void StoreLayerData(int z, byte[] image_data)
	{
		for (int y = 0; y < m_ImageHeight; y++)
		{
			for (int x = 0; x < m_ImageWidth; x++)
			{
				int index = y * m_ImageWidth + x;
				m_VoxelData[x, y, z] = image_data[index];
			}
		}
	}
	
	private async Task GenerateMeshWithCulling()
	{
		var stopwatch = System.Diagnostics.Stopwatch.StartNew();
		
		await Task.Run(() =>
		{
			var slice_results = new (List<Vector3> vertices, List<int> indices)[m_ExpectedImages];

			Parallel.For(0, m_ExpectedImages, z =>
			{
				var local_vertices = new List<Vector3>();
				var local_indices = new List<int>();

				for (int y = 0; y < m_ImageHeight; y++)
				{
					for (int x = 0; x < m_ImageWidth; x++)
					{
						if (m_VoxelData[x, y, z] <= m_Threshold) continue;

						Vector3 pos = new Vector3(x * m_Spacing.X, y * m_Spacing.Y, z * m_Spacing.Z);
						AddCubeFacesWithCulling(local_vertices, local_indices, pos, x, y, z);
					}
				}

				slice_results[z] = (local_vertices, local_indices);
			});

			var vertices = new List<Vector3>();
			var indices = new List<int>();
			int vertex_offset = 0;

			for (int z = 0; z < m_ExpectedImages; z++)
			{
				var (slice_vertices, slice_indices) = slice_results[z];
				
				vertices.AddRange(slice_vertices);
				
				foreach (int index in slice_indices)
				{
					indices.Add(index + vertex_offset);
				}
				
				vertex_offset += slice_vertices.Count;
			}

			if (vertices.Count == 0)
			{
				CallDeferred(MethodName.EmitSignal, SignalName.MeshReady, (ArrayMesh)null);
				return;
			}

			var vertex_array = vertices.ToArray();
			var index_array = indices.ToArray();

			var array_mesh = new ArrayMesh();
			var arrays = new Godot.Collections.Array();
			arrays.Resize((int)Mesh.ArrayType.Max);
			arrays[(int)Mesh.ArrayType.Vertex] = vertex_array;
			arrays[(int)Mesh.ArrayType.Index] = index_array;
			arrays[(int)Mesh.ArrayType.Normal] = CalculateNormals(vertex_array, index_array);

			array_mesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, arrays);

			CallDeferred(MethodName.EmitSignal, SignalName.MeshReady, array_mesh);
		});
		
		stopwatch.Stop();
		GD.Print($"Mesh generation time: {stopwatch.ElapsedMilliseconds}ms");
	}
	
	private void AddCubeFacesWithCulling(List<Vector3> vertices, List<int> indices, Vector3 pos, int x, int y, int z)
	{
		int base_vertex = vertices.Count;
		
		if (!HasVoxelAt(x, y, z - 1))
		{
			vertices.AddRange(new Vector3[] {
				pos,
				new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z),
				new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z),
				new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z)
			});
			indices.AddRange(new int[] { base_vertex, base_vertex + 1, base_vertex + 2, base_vertex, base_vertex + 2, base_vertex + 3 });
			base_vertex += 4;
		}
		
		if (!HasVoxelAt(x, y, z + 1))
		{
			vertices.AddRange(new Vector3[] {
				new Vector3(pos.X, pos.Y, pos.Z + m_VoxelSize),
				new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize),
				new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize),
				new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z + m_VoxelSize)
			});
			indices.AddRange(new int[] { base_vertex, base_vertex + 1, base_vertex + 2, base_vertex, base_vertex + 2, base_vertex + 3 });
			base_vertex += 4;
		}
		
		if (!HasVoxelAt(x - 1, y, z))
		{
			vertices.AddRange(new Vector3[] {
				pos,
				new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z),
				new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize),
				new Vector3(pos.X, pos.Y, pos.Z + m_VoxelSize)
			});
			indices.AddRange(new int[] { base_vertex, base_vertex + 1, base_vertex + 2, base_vertex, base_vertex + 2, base_vertex + 3 });
			base_vertex += 4;
		}
		
		if (!HasVoxelAt(x + 1, y, z))
		{
			vertices.AddRange(new Vector3[] {
				new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z),
				new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z + m_VoxelSize),
				new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize),
				new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z)
			});
			indices.AddRange(new int[] { base_vertex, base_vertex + 1, base_vertex + 2, base_vertex, base_vertex + 2, base_vertex + 3 });
			base_vertex += 4;
		}
		
		if (!HasVoxelAt(x, y - 1, z))
		{
			vertices.AddRange(new Vector3[] {
				pos,
				new Vector3(pos.X, pos.Y, pos.Z + m_VoxelSize),
				new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z + m_VoxelSize),
				new Vector3(pos.X + m_VoxelSize, pos.Y, pos.Z)
			});
			indices.AddRange(new int[] { base_vertex, base_vertex + 1, base_vertex + 2, base_vertex, base_vertex + 2, base_vertex + 3 });
			base_vertex += 4;
		}
		
		if (!HasVoxelAt(x, y + 1, z))
		{
			vertices.AddRange(new Vector3[] {
				new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z),
				new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z),
				new Vector3(pos.X + m_VoxelSize, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize),
				new Vector3(pos.X, pos.Y + m_VoxelSize, pos.Z + m_VoxelSize)
			});
			indices.AddRange(new int[] { base_vertex, base_vertex + 1, base_vertex + 2, base_vertex, base_vertex + 2, base_vertex + 3 });
		}
	}
	
	private bool HasVoxelAt(int x, int y, int z)
	{
		if (!m_VoxelDataReady) return false;
		if (x < 0 || x >= m_ImageWidth || y < 0 || y >= m_ImageHeight || z < 0 || z >= m_ExpectedImages)
			return false;
		
		return m_VoxelData[x, y, z] > m_Threshold;
	}
	
	public void VoxelizeFromBuffer()
	{
		if (m_ProcessedImages < m_ExpectedImages)
		{
			GD.PrintErr("Not ready for meshing");
			CallDeferred(MethodName.EmitSignal, SignalName.MeshReady, (ArrayMesh)null);
			return;
		}
		
		m_IsCapturing = false;
	}
	
	private Vector3[] CalculateNormals(Vector3[] vertices, int[] indices)
	{
		var normals = new Vector3[vertices.Length];
		
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
		}
		
		for (int i = 0; i < normals.Length; i++)
		{
			if (normals[i].LengthSquared() == 0.0f)
			{
				normals[i] = Vector3.Up;
			}
		}
		
		return normals;
	}
}
