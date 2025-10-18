// [ID]
// Sierpinski dodecahedron Dupe C
// [OFFICIAL]
// [KIFS]
// [VARS]
// vec3 offset[(-1, -1, -1), (1, 1, 1)] = (1, 1, 1)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// float scale[1.0, 3.0] = 2.61803398875
// [CODE]

void sierpinskidodecahedrondupec_iter(inout vec4 p4, inout float dz, vec4 original_z, float orbit, int i) {
	vec3 z = p4.xyz;

	vec3 n1 = normalize(vec3(-1.0, golden_ratio - 1.0, 1.0 / (golden_ratio - 1.0)));
	vec3 n2 = normalize(vec3(golden_ratio - 1.0, 1.0 / (golden_ratio - 1.0), -1.0));
	vec3 n3 = normalize(vec3(1.0 / (golden_ratio - 1.0), -1.0, golden_ratio - 1.0));
	float scale = fsierpinskidodecahedrondupec_scale;
	vec3 offset = fsierpinskidodecahedrondupec_offset;

	z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation1);

	z -= 2.0 * min(0.0, dot(z, n1)) * n1;
	z -= 2.0 * min(0.0, dot(z, n2)) * n2;
	z -= 2.0 * min(0.0, dot(z, n3)) * n3;
	z -= 2.0 * min(0.0, dot(z, n1)) * n1;
	z -= 2.0 * min(0.0, dot(z, n2)) * n2;
	z -= 2.0 * min(0.0, dot(z, n3)) * n3;
	z -= 2.0 * min(0.0, dot(z, n1)) * n1;
	z -= 2.0 * min(0.0, dot(z, n2)) * n2;
	z -= 2.0 * min(0.0, dot(z, n3)) * n3;

	z = z * scale - offset * (scale - 1.0);
	dz = dz * abs(scale) + 1.5;

	z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation2);

	p4.xyz = z;
}

//vec2 sierpinskidodecahedrondupec_sdf(vec3 z) {
	//float scale = fsierpinskidodecahedrondupec_scale;
	//vec3 n1 = normalize(vec3(-1.0, golden_ratio - 1.0, 1.0 / (golden_ratio - 1.0)));
	//vec3 n2 = normalize(vec3(golden_ratio - 1.0, 1.0 / (golden_ratio - 1.0), -1.0));
	//vec3 n3 = normalize(vec3(1.0 / (golden_ratio - 1.0), -1.0, golden_ratio - 1.0));
	//vec3 offset = fsierpinskidodecahedrondupec_offset;
	//float orbit_trap = 100000.0;
	//float s = 1.0;
	//float r;
	//int n = 0;
//
	//for (; n < iterations; n++) {
		//z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation1);
//
		//z -= 2.0 * min(0.0, dot(z, n1)) * n1;
		//z -= 2.0 * min(0.0, dot(z, n2)) * n2;
		//z -= 2.0 * min(0.0, dot(z, n3)) * n3;
		//z -= 2.0 * min(0.0, dot(z, n1)) * n1;
		//z -= 2.0 * min(0.0, dot(z, n2)) * n2;
		//z -= 2.0 * min(0.0, dot(z, n3)) * n3;
		//z -= 2.0 * min(0.0, dot(z, n1)) * n1;
		//z -= 2.0 * min(0.0, dot(z, n2)) * n2;
		//z -= 2.0 * min(0.0, dot(z, n3)) * n3;
//
		//z = z * scale - offset * (scale - 1.0);
		//s /= scale;
//
		//z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation2);
//
		//r = dot(z, z);
		//if (coloring_mode == 0 && n > color_min_iterations && n < color_max_iterations) orbit_trap = min(orbit_trap, abs(r));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(z, n));
		//if (r > 1e6) break;
	//}
//
	//float d = fsierpinskidodecahedrondupec_cube_de ? cube_sdf3d(z, vec3(1.0)) * s : dodecahedron_sdf3d(z, 1.0) * s;
	//return vec2(d, orbit_trap);
//}

//vec2 sierpinskidodecahedrondupec_sdf(vec3 z) {
	//float scale = power + 1.0 - 0.38196601125;
//
	//vec3 n1 = normalize(vec3(-1.0, golden_ratio - 1.0, 1.0 / (golden_ratio - 1.0)));
	//vec3 n2 = normalize(vec3(golden_ratio - 1.0, 1.0 / (golden_ratio - 1.0), -1.0));
	//vec3 n3 = normalize(vec3(1.0 / (golden_ratio - 1.0), -1.0, golden_ratio - 1.0));
	//vec3 offset = fsierpinskidodecahedrondupec_offset;
	//float orbit_trap = 100000.0;
	//float s = 1.0;
	//float r;
	//int n = 0;
//
	//for (; n < iterations; n++) {
		//z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation1);
//
		//// tree cube
		//if (z.x - z.y > 0.0) z.xy = z.yx;
		//z = abs(z);
//
		////// emerald block
		////if (z.x - z.y > 0.0) z.xy = z.yx;
		////z.y=abs(z.y);
//
		//// emerald block
		////z.xy = abs(z.xy);
		////if (z.x - z.y > 0.0) z.xy = z.yx;
//
		//// arrow
		////if (z.x - z.y > 0.0) z.xy = z.yx;
		////z.x=abs(z.x);
//
		//vec3 dir1 = normalize(fsierpinskidodecahedrondupec_dir1);
		//vec3 dir2 = normalize(fsierpinskidodecahedrondupec_dir2);
		//vec3 dir3 = normalize(fsierpinskidodecahedrondupec_dir3);
		////vec3 dir3 = normalize(vec3(1.0, 1.0, 1.5));
		//z -= 2.0 * min(0.0, dot(z, dir1)) * dir1;
		//z -= 2.0 * min(0.0, dot(z, dir2)) * dir2;
		////z -= 2.0 * min(0.0, dot(z, dir3)) * dir3;
		////z -= 2.0 * min(0.0, dot(z, n2)) * n2;
		////z -= 2.0 * min(0.0, dot(z, n1)) * n1;
		////z -= 2.0 * min(0.0, dot(z, n2)) * n2;
		////z -= 2.0 * min(0.0, dot(z, n3)) * n3;
		////z -= 2.0 * min(0.0, dot(z, n1)) * n1;
		////z -= 2.0 * min(0.0, dot(z, n2)) * n2;
		////z -= 2.0 * min(0.0, dot(z, n3)) * n3;
//
		//z = z * scale - offset * (scale - 1.0);
		//s /= scale;
//
		//z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation2);
//
		//r = dot(z, z);
		//if (coloring_mode == 0) orbit_trap = min(orbit_trap, abs(r));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(z));
		//if (r > 1e6) break;
	//}
//
	//// float d = 0.99 * length(z) * pow(scale, float(-n - 1));
	//float d = fsierpinskidodecahedrondupec_cube_de ? cube_sdf3d(z, vec3(1.0)) * s : dodecahedron_sdf3d(z, 1.0) * s;
	//return vec2(d, orbit_trap);
//}


//vec2 sierpinskidodecahedrondupec_sdf(vec3 z) {
    //float scale = power + 1.0 - 0.38196601125;
    //vec3 offset = fsierpinskidodecahedrondupec_offset;
    //float orbit_trap = 100000.0;
    //float s = 1.0;
    //float r;
    //int n = 0;
//
    //for (; n < iterations; n++) {
        //z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation1);
//
        //// Use abs() to create symmetrical copies without removing the central structure
        //z.x += 1.0;
//
        //z = z * scale - offset * (scale - 1.0);
        //s /= scale;
//
        //z = rotate3d_point(z, fsierpinskidodecahedrondupec_rotation2);
//
        //r = dot(z, z);
        //if (coloring_mode == 0) orbit_trap = min(orbit_trap, abs(r));
        //else orbit_trap = min(orbit_trap, process_orbit_trap(z));
//
        //if (r > 1e6) break;
    //}
//
    //float d = fsierpinskidodecahedrondupec_cube_de ?
              //cube_sdf3d(z, vec3(1.0)) * s :
              //dodecahedron_sdf3d(z, 1.0) * s;
//
    //return vec2(d, orbit_trap);
//}
