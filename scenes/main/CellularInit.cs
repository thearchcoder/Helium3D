using Godot;
using System;
using System.Threading.Tasks;
using System.Linq;

public struct CellData
{
	public byte m_State;
	public byte m_Generation;
	public byte m_ColorType;

	public CellData(byte state, byte generation = 0, byte color_type = 0)
	{
		m_State = state;
		m_Generation = generation;
		m_ColorType = color_type;
	}

	public bool m_IsAlive => m_State > 0;
}

public partial class CellularInit : Node
{
	private const bool USE_PRECOMPUTED_DISTANCE_FIELD = false;
	private static readonly Vector3 BOUNDS = new Vector3(2.0f, 2.0f, 2.0f);
	private const int PADDING = 1;
	private const float RANDOM_DENSITY = 0.5f;

	private const int COLOR_MODE_DISTANCE = 0;
	private const int COLOR_MODE_GENERATION = 1;
	private const int COLOR_MODE_BIRTH_SURVIVE = 2;
	private const int COLOR_MODE_STATE = 3;

	private int m_TextureSize = 30;
	private int m_CellularSize;
	private float m_Center;
	private string m_CaRules = "3/45678/2/M";
	
	private int[] m_MooreOffsets;
	private int[] m_VonNeumannOffsets;

	private CellData[] m_CellularGrid = [];
	private CellData[] m_NewGrid = [];
	private byte[] m_TextureData;
	private bool m_PrevForward = false;
	private bool m_PrevReset = false;
	private int m_PrevInitialPattern = 2;
	private float m_PrevRadius = 3.0f;
	private int m_PrevColorMode = COLOR_MODE_DISTANCE;
	private string m_PrevCaRules = "3/45678/2/M";
	private int m_PrevTextureSize = 30;

	private string m_InitialPattern = "cross";
	private float m_Radius = 3.0f;
	private int m_ColorMode = COLOR_MODE_DISTANCE;
	private int m_CurrentGeneration = 0;

	private int[] m_SurvivalRules;
	private int[] m_BirthRules;
	private int m_States = 2;
	private bool m_UseVonNeumann;

	public override void _Process(double delta)
	{
		var fields = GetTree().CurrentScene.Get("fields").AsGodotDictionary();

		var current_forward = fields.ContainsKey("fcellular_forward") ? fields["fcellular_forward"].AsBool() : m_PrevForward;
		var current_reset = fields.ContainsKey("fcellular_reset") ? fields["fcellular_reset"].AsBool() : m_PrevReset;
		var current_initial_pattern = fields.ContainsKey("fcellular_initial_pattern") ? fields["fcellular_initial_pattern"].AsInt32() : m_PrevInitialPattern;
		var current_radius = fields.ContainsKey("fcellular_radius") ? fields["fcellular_radius"].AsSingle() : m_PrevRadius;
		var current_ca_rules = fields.ContainsKey("fcellular_rules") ? fields["fcellular_rules"].AsString() : m_PrevCaRules;
		var current_texture_size = fields.ContainsKey("fcellular_size") ? fields["fcellular_size"].AsInt32() : m_PrevTextureSize;

		if (current_forward != m_PrevForward)
		{
			m_PrevForward = current_forward;
			Forward();
		}

		if (current_reset != m_PrevReset)
		{
			m_PrevReset = current_reset;
			ResetCellularGrid();
		}

		if (current_initial_pattern != m_PrevInitialPattern)
		{
			m_PrevInitialPattern = current_initial_pattern;
			m_InitialPattern = GetPatternNameFromId(current_initial_pattern);
		}

		if (Math.Abs(current_radius - m_PrevRadius) > 0.01f)
		{
			m_PrevRadius = current_radius;
			m_Radius = current_radius + 1.0f;
		}

		if (current_ca_rules != m_PrevCaRules)
		{
			m_PrevCaRules = current_ca_rules;
			m_CaRules = current_ca_rules;
			ParseCaRules(m_CaRules);
		}

		if (current_texture_size != m_PrevTextureSize)
		{
			m_PrevTextureSize = current_texture_size;
			m_TextureSize = current_texture_size;
			m_CellularSize = m_TextureSize;
			m_Center = m_CellularSize / 2.0f;
			CalculateNeighborOffsets();
			GenerateCellularAutomata();
			UpdateShaderParameters();
		}
	}

	private void CalculateNeighborOffsets()
	{
		m_MooreOffsets = new int[]
		{
			-m_CellularSize * m_CellularSize - m_CellularSize - 1, -m_CellularSize * m_CellularSize - m_CellularSize, -m_CellularSize * m_CellularSize - m_CellularSize + 1,
			-m_CellularSize * m_CellularSize - 1, -m_CellularSize * m_CellularSize, -m_CellularSize * m_CellularSize + 1,
			-m_CellularSize * m_CellularSize + m_CellularSize - 1, -m_CellularSize * m_CellularSize + m_CellularSize, -m_CellularSize * m_CellularSize + m_CellularSize + 1,

			-m_CellularSize - 1, -m_CellularSize, -m_CellularSize + 1,
			-1, 1,
			m_CellularSize - 1, m_CellularSize, m_CellularSize + 1,

			m_CellularSize * m_CellularSize - m_CellularSize - 1, m_CellularSize * m_CellularSize - m_CellularSize, m_CellularSize * m_CellularSize - m_CellularSize + 1,
			m_CellularSize * m_CellularSize - 1, m_CellularSize * m_CellularSize, m_CellularSize * m_CellularSize + 1,
			m_CellularSize * m_CellularSize + m_CellularSize - 1, m_CellularSize * m_CellularSize + m_CellularSize, m_CellularSize * m_CellularSize + m_CellularSize + 1
		};

		m_VonNeumannOffsets = new int[]
		{
			-m_CellularSize * m_CellularSize, m_CellularSize * m_CellularSize,
			-m_CellularSize, m_CellularSize,
			-1, 1
		};
	}

	private string GetPatternNameFromId(int pattern_id)
	{
		return pattern_id switch
		{
			0 => "random",
			1 => "center_sphere",
			2 => "cube",
			3 => "vertical_column",
			4 => "horizontal_plane",
			5 => "corners",
			6 => "edges",
			7 => "cross",
			_ => "cube"
		};
	}

	private void ParseCaRules(string rules)
	{
		var parts = rules.Split('/');
		if (parts.Length < 2)
		{
			GD.PrintErr($"invalid ca rules format: {rules}");
			m_SurvivalRules = new int[] { 4 };
			m_BirthRules = new int[] { 5 };
			m_States = 2;
			m_UseVonNeumann = false;
			PrintParsedRules();
			return;
		}
		
		string first_part = parts[0].ToUpper();
		string second_part = parts[1].ToUpper();
		
		if (first_part.StartsWith("B") && second_part.StartsWith("S"))
		{
			m_BirthRules = ParseNumberRange(first_part.Substring(1));
			m_SurvivalRules = ParseNumberRange(second_part.Substring(1));
		}
		else if (first_part.StartsWith("S") && second_part.StartsWith("B"))
		{
			m_SurvivalRules = ParseNumberRange(first_part.Substring(1));
			m_BirthRules = ParseNumberRange(second_part.Substring(1));
		}
		else
		{
			m_SurvivalRules = ParseNumberRange(first_part);
			m_BirthRules = ParseNumberRange(second_part);
		}
		
		m_States = 2;
		m_UseVonNeumann = false;
		
		for (int i = 2; i < parts.Length; i++)
		{
			string part = parts[i].ToUpper();
			if (part == "VN" || part == "V" || part == "N")
			{
				m_UseVonNeumann = true;
			}
			else if (part == "M" || part == "MOORE")
			{
				m_UseVonNeumann = false;
			}
			else if (int.TryParse(part, out int state_count))
			{
				m_States = Math.Max(2, state_count);
			}
		}
		
		PrintParsedRules();
	}

	private void PrintParsedRules()
	{
		//GD.Print("=== Parsed CA Rules ===");
		//GD.Print($"Birth Rules: [{string.Join(", ", m_BirthRules)}]");
		//GD.Print($"Survival Rules: [{string.Join(", ", m_SurvivalRules)}]");
		//GD.Print($"States: {m_States}");
		//GD.Print($"Neighborhood: {(m_UseVonNeumann ? "Von Neumann" : "Moore")}");
		//GD.Print("=====================");
	}

	private int[] ParseNumberRange(string range_str)
	{
		if (string.IsNullOrEmpty(range_str))
			return new int[0];

		if (range_str.Contains('-'))
		{
			var range_parts = range_str.Split('-');
			if (range_parts.Length == 2 && int.TryParse(range_parts[0], out int start) && int.TryParse(range_parts[1], out int end))
			{
				return Enumerable.Range(start, end - start + 1).ToArray();
			}
		}

		if (range_str.Contains(','))
		{
			return range_str.Split(',')
				.Where(s => int.TryParse(s.Trim(), out _))
				.Select(s => int.Parse(s.Trim()))
				.ToArray();
		}

		return range_str.ToCharArray()
			.Where(c => char.IsDigit(c))
			.Select(c => int.Parse(c.ToString()))
			.ToArray();
	}

	private int GetIndex(int x, int y, int z) {
		return x * m_CellularSize * m_CellularSize + y * m_CellularSize + z;
	}

	private bool IsInPaddingZone(int x, int y, int z) {
		return x <= PADDING || x >= m_CellularSize - PADDING ||
			   y <= PADDING || y >= m_CellularSize - PADDING ||
			   z <= PADDING || z >= m_CellularSize - PADDING;
	}

	private byte GetInitialPatternValue(int x, int y, int z) {
		switch (m_InitialPattern)
		{
			case "random":
				float dist_from_center = new Vector3(x - m_Center, y - m_Center, z - m_Center).Length();
				if (dist_from_center <= m_Radius && GD.Randf() < RANDOM_DENSITY)
					return (byte)(GD.RandRange(1, m_States));
				return 0;
			case "center_sphere":
				float dist = new Vector3(x - m_Center, y - m_Center, z - m_Center).Length();
				return dist <= m_Radius ? (byte)(m_States - 1) : (byte)0;
			case "cube":
				if (Math.Abs(x - m_Center) <= m_Radius &&
					Math.Abs(y - m_Center) <= m_Radius &&
					Math.Abs(z - m_Center) <= m_Radius)
					return (byte)(m_States - 1);
				return 0;
			case "vertical_column":
				float dist2d = new Vector2(x - m_Center, z - m_Center).Length();
				return dist2d <= m_Radius ? (byte)(m_States - 1) : (byte)0;
			case "horizontal_plane":
				return Math.Abs(y - m_Center) <= m_Radius ? (byte)(m_States - 1) : (byte)0;
			case "corners":
				float corner_size = m_Radius;
				if ((x < corner_size && y < corner_size && z < corner_size) ||
					(x >= m_CellularSize - corner_size && y >= m_CellularSize - corner_size && z >= m_CellularSize - corner_size))
					return (byte)(m_States - 1);
				return 0;
			case "edges":
				int edge_thickness = (int)m_Radius;
				if (x < edge_thickness || x >= m_CellularSize - edge_thickness ||
					y < edge_thickness || y >= m_CellularSize - edge_thickness ||
					z < edge_thickness || z >= m_CellularSize - edge_thickness)
					return (byte)(m_States - 1);
				return 0;
			case "cross":
				if ((Math.Abs(x - m_Center) <= 1 && Math.Abs(y - m_Center) <= m_Radius && Math.Abs(z - m_Center) <= 1) ||
					(Math.Abs(x - m_Center) <= m_Radius && Math.Abs(y - m_Center) <= 1 && Math.Abs(z - m_Center) <= 1) ||
					(Math.Abs(x - m_Center) <= 1 && Math.Abs(y - m_Center) <= 1 && Math.Abs(z - m_Center) <= m_Radius))
					return (byte)(m_States - 1);
				return 0;
			default:
				float default_dist = new Vector3(x - m_Center, y - m_Center, z - m_Center).Length();
				if (default_dist <= m_Radius && GD.Randf() < RANDOM_DENSITY)
					return (byte)(GD.RandRange(1, m_States));
				return 0;
		}
	}

	private byte GetColorType(int x, int y, int z, byte state)
	{
		if (state == 0) return 0;

		switch (m_ColorMode)
		{
			case COLOR_MODE_DISTANCE:
				float dist = new Vector3(x - m_Center, y - m_Center, z - m_Center).Length();
				float normalized_dist = Math.Min(dist / (m_CellularSize * 0.5f), 1.0f);
				return (byte)Math.Min((int)(normalized_dist * 7) + 1, 7);

			case COLOR_MODE_GENERATION:
				return (byte)Math.Min(m_CurrentGeneration % 7 + 1, 7);

			case COLOR_MODE_STATE:
				return (byte)Math.Min(state, (byte)7);

			case COLOR_MODE_BIRTH_SURVIVE:
			default:
				return 1;
		}
	}

	private void GenerateCellularAutomata() {
		int total_size = m_CellularSize * m_CellularSize * m_CellularSize;
		m_CellularGrid = new CellData[total_size];
		m_NewGrid = new CellData[total_size];
		m_TextureData = new byte[total_size * 3];
		m_CurrentGeneration = 0;

		Parallel.For(0, m_CellularSize, x =>
		{
			for (int y = 0; y < m_CellularSize; y++)
			{
				for (int z = 0; z < m_CellularSize; z++)
				{
					int index = GetIndex(x, y, z);
					byte state = IsInPaddingZone(x, y, z) ? (byte)0 : GetInitialPatternValue(x, y, z);
					byte color_type = GetColorType(x, y, z, state);
					m_CellularGrid[index] = new CellData(state, 0, color_type);
				}
			}
		});
	}

	private void ResetCellularGrid()
	{
		m_CurrentGeneration = 0;

		Parallel.For(0, m_CellularSize, x =>
		{
			for (int y = 0; y < m_CellularSize; y++)
			{
				for (int z = 0; z < m_CellularSize; z++)
				{
					int index = GetIndex(x, y, z);
					byte state = IsInPaddingZone(x, y, z) ? (byte)0 : GetInitialPatternValue(x, y, z);
					byte color_type = GetColorType(x, y, z, state);
					m_CellularGrid[index] = new CellData(state, 0, color_type);
				}
			}
		});

		UpdateShaderParameters();
	}

	private int CountNeighborsFlat(int index, int x, int y, int z)
	{
		int count = 0;
		int[] offsets = m_UseVonNeumann ? m_VonNeumannOffsets : m_MooreOffsets;

		foreach (int offset in offsets)
		{
			int neighbor_index = index + offset;

			if (neighbor_index >= 0 && neighbor_index < m_CellularGrid.Length)
			{
				int nx = neighbor_index / (m_CellularSize * m_CellularSize);
				int remainder = neighbor_index % (m_CellularSize * m_CellularSize);
				int ny = remainder / m_CellularSize;
				int nz = remainder % m_CellularSize;

				int max_distance = m_UseVonNeumann ? 1 : 1;
				if (Math.Abs(nx - x) <= max_distance && Math.Abs(ny - y) <= max_distance && Math.Abs(nz - z) <= max_distance)
				{
					if (m_CellularGrid[neighbor_index].m_IsAlive) count++;
				}
			}
		}

		return count;
	}

	private void ApplySingleIteration()
	{
		m_CurrentGeneration++;

		Parallel.For(0, m_CellularSize, x =>
		{
			for (int y = 0; y < m_CellularSize; y++)
			{
				for (int z = 0; z < m_CellularSize; z++)
				{
					int index = GetIndex(x, y, z);

					if (IsInPaddingZone(x, y, z))
					{
						m_NewGrid[index] = new CellData(0);
					}
					else
					{
						int neighbors = CountNeighborsFlat(index, x, y, z);
						var current = m_CellularGrid[index];

						byte new_state = 0;

						if (current.m_State == 0)
						{
							if (m_BirthRules.Contains(neighbors))
								new_state = 1;
						}
						else
						{
							if (m_SurvivalRules.Contains(neighbors))
							{
								new_state = current.m_State;
							}
							else if (m_States > 2)
							{
								new_state = (byte)Math.Max(0, current.m_State - 1);
							}
						}

						byte generation = new_state > 0 ?
							(current.m_State > 0 ? (byte)(current.m_Generation + 1) : (byte)1) :
							(byte)0;

						byte color_type = 0;
						if (new_state > 0)
						{
							if (m_ColorMode == COLOR_MODE_BIRTH_SURVIVE)
							{
								color_type = current.m_State > 0 ? (byte)2 : (byte)1;
							}
							else
							{
								color_type = GetColorType(x, y, z, new_state);
							}
						}

						m_NewGrid[index] = new CellData(new_state, generation, color_type);
					}
				}
			}
		});

		(m_CellularGrid, m_NewGrid) = (m_NewGrid, m_CellularGrid);
	}

	private Vector3 GetColorFromType(byte color_type)
	{
		return color_type switch
		{
			0 => new Vector3(0.0f, 0.0f, 0.0f),
			1 => new Vector3(1.0f, 0.0f, 0.0f),
			2 => new Vector3(0.0f, 1.0f, 0.0f),
			3 => new Vector3(0.0f, 0.0f, 1.0f),
			4 => new Vector3(1.0f, 1.0f, 0.0f),
			5 => new Vector3(1.0f, 0.0f, 1.0f),
			6 => new Vector3(0.0f, 1.0f, 1.0f),
			7 => new Vector3(1.0f, 1.0f, 1.0f),
			_ => new Vector3(0.5f, 0.5f, 0.5f)
		};
	}

	private void UpdateShaderParameters()
	{
		if (USE_PRECOMPUTED_DISTANCE_FIELD)
		{
			var distance_texture = CreateDistanceFieldCpu();
			var bounds_uniform = new Vector3(BOUNDS.X, BOUNDS.Y, BOUNDS.Z);

			var fractal = GetNode("%Fractal");
			var material = fractal.Get("material_override").As<ShaderMaterial>();
			material.SetShaderParameter("fcellular_voxel_data", distance_texture);
			material.SetShaderParameter("fcellular_voxel_bounds", bounds_uniform);
			material.SetShaderParameter("fcellular_voxel_grid_size", m_TextureSize);
			material.SetShaderParameter("fcellular_use_distance_field", true);
		}
		else
		{
			var cellular_texture = CreateCellularTexture();
			var bounds_uniform = new Vector3(BOUNDS.X, BOUNDS.Y, BOUNDS.Z);

			var fractal = GetNode("%Fractal");
			var material = fractal.Get("material_override").As<ShaderMaterial>();
			material.SetShaderParameter("fcellular_voxel_data", cellular_texture);
			material.SetShaderParameter("fcellular_voxel_bounds", bounds_uniform);
			material.SetShaderParameter("fcellular_voxel_grid_size", m_CellularSize);
			material.SetShaderParameter("fcellular_use_distance_field", false);
		}
	}

	private void Forward()
	{
		ApplySingleIteration();
		UpdateShaderParameters();
	}

	private ImageTexture3D CreateCellularTexture()
	{
		Parallel.For(0, m_CellularSize * m_CellularSize * m_CellularSize, i =>
		{
			var cell = m_CellularGrid[i];
			var color = GetColorFromType(cell.m_ColorType);

			m_TextureData[i * 3] = (byte)(color.X * 255);
			m_TextureData[i * 3 + 1] = (byte)(color.Y * 255);
			m_TextureData[i * 3 + 2] = (byte)(color.Z * 255);
		});

		var images = new Godot.Collections.Array<Image>();

		for (int z = 0; z < m_CellularSize; z++)
		{
			var layer_image = Image.Create(m_CellularSize, m_CellularSize, false, Image.Format.Rgb8);

			for (int y = 0; y < m_CellularSize; y++)
			{
				for (int x = 0; x < m_CellularSize; x++)
				{
					int index = GetIndex(x, y, z);
					byte r = m_TextureData[index * 3];
					byte g = m_TextureData[index * 3 + 1];
					byte b = m_TextureData[index * 3 + 2];

					layer_image.SetPixel(x, y, new Color(r / 255.0f, g / 255.0f, b / 255.0f, 1.0f));
				}
			}

			images.Add(layer_image);
		}

		var texture = new ImageTexture3D();
		texture.Create(Image.Format.Rgb8, m_CellularSize, m_CellularSize, m_CellularSize, false, images);
		return texture;
	}

	private ImageTexture3D CreateDistanceFieldCpu()
	{
		var images = new Image[m_TextureSize];

		Parallel.For(0, m_TextureSize, z =>
		{
			float layer_z = ((float)z / (m_TextureSize - 1) - 0.5f) * BOUNDS.Z;
			var layer_image = Image.Create(m_TextureSize, m_TextureSize, false, Image.Format.Rgb8);

			for (int y = 0; y < m_TextureSize; y++)
			{
				for (int x = 0; x < m_TextureSize; x++)
				{
					float world_x = ((float)x / (m_TextureSize - 1) - 0.5f) * BOUNDS.X;
					float world_y = ((float)y / (m_TextureSize - 1) - 0.5f) * BOUNDS.Y;
					var world_pos = new Vector3(world_x, world_y, layer_z);

					var result = DistanceToCellularWithColor(world_pos);
					float normalized_dist = Mathf.Clamp(result.X / 2.0f, 0.0f, 1.0f);

					if (result.X < 0.01f)
					{
						layer_image.SetPixel(x, y, new Color(result.Y, result.Z, result.W, 1.0f));
					}
					else
					{
						layer_image.SetPixel(x, y, new Color(0.0f, 0.0f, 0.0f, 1.0f));
					}
				}
			}

			images[z] = layer_image;
		});

		var godot_images = new Godot.Collections.Array<Image>();
		for (int i = 0; i < m_TextureSize; i++)
		{
			godot_images.Add(images[i]);
		}

		var texture = new ImageTexture3D();
		texture.Create(Image.Format.Rgb8, m_TextureSize, m_TextureSize, m_TextureSize, false, godot_images);
		return texture;
	}

	private Vector3I WorldToCellular(Vector3 pos)
	{
		var normalized = (pos + BOUNDS * 0.5f) / BOUNDS;
		var grid_pos = normalized * m_CellularSize;
		return new Vector3I(
			Mathf.Clamp((int)grid_pos.X, 0, m_CellularSize - 1),
			Mathf.Clamp((int)grid_pos.Y, 0, m_CellularSize - 1),
			Mathf.Clamp((int)grid_pos.Z, 0, m_CellularSize - 1)
		);
	}

	private Vector4 DistanceToCellularWithColor(Vector3 pos)
	{
		var grid_coord = WorldToCellular(pos);
		float min_dist = 1000.0f;
		float voxel_size = BOUNDS.X / m_CellularSize;
		Vector3 closest_color = new Vector3(0.0f, 0.0f, 0.0f);

		for (int dx = -1; dx <= 1; dx++)
		{
			for (int dy = -1; dy <= 1; dy++)
			{
				for (int dz = -1; dz <= 1; dz++)
				{
					int check_x = grid_coord.X + dx;
					int check_y = grid_coord.Y + dy;
					int check_z = grid_coord.Z + dz;

					if (check_x >= 0 && check_x < m_CellularSize &&
						check_y >= 0 && check_y < m_CellularSize &&
						check_z >= 0 && check_z < m_CellularSize)
					{
						int index = GetIndex(check_x, check_y, check_z);
						var cell = m_CellularGrid[index];
						if (cell.m_IsAlive)
						{
							var voxel_center = new Vector3(
								(check_x + 0.5f) / m_CellularSize * BOUNDS.X - BOUNDS.X * 0.5f,
								(check_y + 0.5f) / m_CellularSize * BOUNDS.Y - BOUNDS.Y * 0.5f,
								(check_z + 0.5f) / m_CellularSize * BOUNDS.Z - BOUNDS.Z * 0.5f
							);
							float dist = Mathf.Max(
								Mathf.Abs(pos.X - voxel_center.X) - voxel_size * 0.5f,
								Mathf.Max(
									Mathf.Abs(pos.Y - voxel_center.Y) - voxel_size * 0.5f,
									Mathf.Abs(pos.Z - voxel_center.Z) - voxel_size * 0.5f
								)
							);
							if (dist < min_dist)
							{
								min_dist = dist;
								closest_color = GetColorFromType(cell.m_ColorType);
							}
						}
					}
				}
			}
		}

		float final_dist = min_dist < 1000.0f ? min_dist : voxel_size;
		return new Vector4(final_dist, closest_color.X, closest_color.Y, closest_color.Z);
	}

	private float DistanceToCellular(Vector3 pos)
	{
		return DistanceToCellularWithColor(pos).X;
	}

	public override void _Ready()
	{
		//m_CellularSize = m_TextureSize;
		//m_Center = m_CellularSize / 2.0f;
		//CalculateNeighborOffsets();
		//ParseCaRules(m_CaRules);
		//UpdateShaderParameters();
	}
}
