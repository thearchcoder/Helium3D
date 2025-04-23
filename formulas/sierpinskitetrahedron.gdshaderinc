// [ID]
// Sierpinski tetrahedron
// [INDEX]
// 6
// [VARS]
// vec3 offset[(-1, -1, -1), (1, 1, 1)] = (1, 1, 1)
// vec3 rotation1[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// vec3 rotation2[(-3.14159, -3.14159, -3.14159), (3.14159, 3.14159, 3.14159)] = (0, 0, 0)
// float scale[1.0, 3.0] = 2.0
// [CODE]
uniform vec3 fsierpinskitetrahedron_rotation1;
uniform vec3 fsierpinskitetrahedron_rotation2;
uniform vec3 fsierpinskitetrahedron_offset;
uniform float fsierpinskitetrahedron_scale;

vec2 sierpinskitetrahedron_sdf(vec3 z) {
	float scale = fsierpinskitetrahedron_scale;
	vec3 offset = fsierpinskitetrahedron_offset;
	float orbit_trap = 1000000.0;
	float r;
	float s = 1.0;
	int n = 0;

	for (; n < iterations; n++) {
		z = rotate3d_point(z, fsierpinskitetrahedron_rotation1);

		if (z.x + z.y < 0.0) z.xy = -z.yx;
		if (z.x + z.z < 0.0) z.xz = -z.zx;
		if (z.y + z.z < 0.0) z.zy = -z.yz;

		z = z * scale - offset * (scale - 1.0);
		s /= scale;
		
		//z.z -=  .5*offset.z*(scale-1.)/scale;
		//z.z  = -abs(z.z);
		//z.z +=  .5*offset.z*(scale-1.)/scale;

		//z *= scale;

		//z.x -= offset.x*(scale-1.);
		//z.y -= offset.y*(scale-1.);  

		if (coloring_mode == 0) orbit_trap = min(orbit_trap, abs(dot(z, z)));
		else orbit_trap = min(orbit_trap, process_orbit_trap(z));
		
		z = rotate3d_point(z, fsierpinskitetrahedron_rotation2);
	}
	
	//float d = length(z) * pow(scale, -float(n));
	float d = triangle_sdf3d(z) * s;
	return vec2(d, orbit_trap);
}

//vec2 sierpinskitetrahedron4d_sdf(vec3 z3d, float power) {
	//vec4 z = vec4(z3d, 0.0);
    //float Scale = power;
    //float Offset = 1.0;
    //float alpha = fsierpinski4d_rotation_x;
    //float beta = fsierpinski4d_rotation_y;
    //float gamma = fsierpinski4d_rotation_z;
	//float orbit_trap = 1000000.0;
//
    //float r;
    //int n = 0;
    //while (n < int(iterations)) {
        //// Folding in 4D
        //if (z.x + z.y < 0.0) z.xy = -z.yx; // fold 1
        //if (z.x + z.z < 0.0) z.xz = -z.zx; // fold 2
        //if (z.y + z.z < 0.0) z.zy = -z.yz; // fold 3
        //if (z.x + z.w < 0.0) z.xw = -z.wx; // fold 4 (new for 4D)
        //if (z.y + z.w < 0.0) z.yw = -z.wy; // fold 5 (new for 4D)
        //if (z.z + z.w < 0.0) z.zw = -z.wz; // fold 6 (new for 4D)
//
        //z = z * Scale - Offset * (Scale - 1.0);
//
        //// 4D Rotations
        //// Y-axis rotation (affects x and z)
        //z.xz = vec2(cos(alpha) * z.x - sin(alpha) * z.z, sin(alpha) * z.x + cos(alpha) * z.z);
        //// X-axis rotation (affects y and z)
        //z.yz = vec2(cos(beta) * z.y - sin(beta) * z.z, sin(beta) * z.y + cos(beta) * z.z);
        //// Z-axis rotation (affects x and y)
        //z.xy = vec2(cos(gamma) * z.x - sin(gamma) * z.y, sin(gamma) * z.x + cos(gamma) * z.y);
        //// W-axis rotation (affects x and w, y and w, z and w)
        //z.xw = vec2(cos(gamma) * z.x - sin(gamma) * z.w, sin(gamma) * z.x + cos(gamma) * z.w);
        //z.yw = vec2(cos(gamma) * z.y - sin(gamma) * z.w, sin(gamma) * z.y + cos(gamma) * z.w);
        //z.zw = vec2(cos(gamma) * z.z - sin(gamma) * z.w, sin(gamma) * z.z + cos(gamma) * z.w);
//
		//orbit_trap = min(orbit_trap, abs(dot(z, z)));
//
        //n++;
    //}
//
    //return vec2(length(z) * pow(Scale, -float(n)), orbit_trap);
//}
