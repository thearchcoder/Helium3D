// [ID]
// Cellular Dupe F
// [DISABLED]
// [OFFICIAL]
// [DIFS]
// [VARS]
// selection initial_pattern[Random, Center Sphere, Cube, Vertical Column, Horizontal Plane, Corners, Edges, Cross] = cube
// int size[10, 100] = 30
// string rules[] = 3/45678/M
// int radius[1, 15] = 3
// bool forward[false, true] = false
// bool reset[false, true] = false
// [CODE]
uniform sampler3D fcellulardupef_voxel_data;
uniform vec3 fcellulardupef_voxel_bounds;
uniform int fcellulardupef_voxel_grid_size;
uniform bool fcellulardupef_use_distance_field;

vec2 cellulardupef_sdf(vec4 z4d) {
	vec3 z = z4d.xyz;
	if (fcellulardupef_use_distance_field) {
		vec3 expanded_bounds = fcellulardupef_voxel_bounds * 2.0;
		vec3 uv = (z + expanded_bounds * 0.5) / expanded_bounds;
		if (any(lessThan(uv, vec3(0.0))) || any(greaterThan(uv, vec3(1.0)))) {
			return vec2(max(cube_sdf3d(z, vec3(1.0)), 0.01), 0.0);
		}
		vec3 color_sample = texture(fcellulardupef_voxel_data, uv).rgb;
		float d = length(color_sample) > 0.1 ? 0.0 : 1.0;
		float orbit_trap = (color_sample.r + color_sample.g * 2.0 + color_sample.b * 4.0) / 7.0;
		return vec2(d, orbit_trap);
	} else {
		vec3 uv = (z + fcellulardupef_voxel_bounds * 0.5) / fcellulardupef_voxel_bounds;
		if (any(lessThan(uv, vec3(0.0))) || any(greaterThan(uv, vec3(1.0)))) {
			return vec2(max(cube_sdf3d(z, vec3(1.0)), 0.01), 0.0);
		}
		vec3 grid_pos = uv * float(fcellulardupef_voxel_grid_size);
		ivec3 base_voxel = ivec3(floor(grid_pos - 0.5));
		float voxel_size = fcellulardupef_voxel_bounds.x / float(fcellulardupef_voxel_grid_size);
		float min_dist = voxel_size * 2.0;
		float closest_orbit_trap = 0.0;
		bool found_surface = false;
		int search_radius = 2;
		for (int dx = -search_radius; dx <= search_radius; dx++) {
			for (int dy = -search_radius; dy <= search_radius; dy++) {
				for (int dz = -search_radius; dz <= search_radius; dz++) {
					ivec3 voxel_coord = base_voxel + ivec3(dx, dy, dz);
					if (any(lessThan(voxel_coord, ivec3(0))) ||
						any(greaterThanEqual(voxel_coord, ivec3(fcellulardupef_voxel_grid_size)))) {
						continue;
					}
					vec3 sample_uv = (vec3(voxel_coord) + 0.5) / float(fcellulardupef_voxel_grid_size);
					vec3 voxel_color = texture(fcellulardupef_voxel_data, sample_uv).rgb;
					if (length(voxel_color) > 0.1) {
						vec3 voxel_center = (vec3(voxel_coord) + 0.5) / float(fcellulardupef_voxel_grid_size);
						voxel_center = (voxel_center - 0.5) * fcellulardupef_voxel_bounds;
						float dist = cube_sdf3d(z - voxel_center, vec3(voxel_size * 0.5));
						if (abs(dist) < min_dist) {
							min_dist = abs(dist);
							closest_orbit_trap = (voxel_color.r + voxel_color.g * 2.0 + voxel_color.b * 4.0) / 7.0;
							found_surface = true;
						}
					}
				}
			}
		}
		if (!found_surface) {
			return vec2(max(cube_sdf3d(z, vec3(1.0)), fcellulardupef_voxel_bounds.x / float(fcellulardupef_voxel_grid_size)), closest_orbit_trap);
		}
		return vec2(min_dist, closest_orbit_trap);
	}
}