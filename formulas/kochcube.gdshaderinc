// [ID]
// Koch cube
// [INDEX]
// 14
// [VARS]
// float scale[0, 3] = 1
// int variant[0, 10] = 0
// bool first_zrev[false, true] = true
// bool pxyzminuss[false, true] = true
// advanced bool psortsymmetry1[false, true] = false
// bool psortsymmetry2[false, true] = false
// bool foldzbefore[false, true] = true
// advanced bool abs_x[false, true] = true
// advanced bool abs_y[false, true] = true
// bool abs_z[false, true] = true
// advanced selection fold1[Disabled, Sign, Minus, Both] = Disabled
// advanced selection fold2[Disabled, Max, Min] = Disabled
// bool fold3[false, true] = true
// bool fold4[false, true] = true
// advanced bool reflection[false, true] = false
// [CODE]
uniform float fkochcube_scale;
uniform int fkochcube_variant;
uniform bool fkochcube_first_zrev;
uniform bool fkochcube_pxyzminuss;
uniform bool fkochcube_psortsymmetry1;
uniform bool fkochcube_psortsymmetry2;
uniform bool fkochcube_foldzbefore;
uniform bool fkochcube_abs_x;
uniform bool fkochcube_abs_y;
uniform bool fkochcube_abs_z;
uniform int fkochcube_fold1;
uniform int fkochcube_fold2;
uniform bool fkochcube_fold3;
uniform bool fkochcube_fold4;
uniform bool fkochcube_reflection;

mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(vec2(c, -s), vec2(s, c));
}

float sdQuad(vec3 p, vec2 s){
    p = abs(p)-vec3(s,0.00001).xzy;
	return length(max(p, 0.0))+min(max(p.x, max(p.y, p.z)), 0.);
}

vec3 psort(vec3 p, bool sort) {
    if (sort) {
        if (p.x > p.y) p.xy = p.yx;
        if (p.x > p.z) p.xz = p.zx;
        if (p.y > p.z) p.yz = p.zy;
        if (p.x > p.y) p.xy = p.yx;
        if (p.x > p.z) p.xz = p.zx;
        if (p.y > p.z) p.yz = p.zy;
    }
    return p;
}

void kochcube_iter(inout vec4 z4, inout float dz, vec4 original_z, float orbit, int i, inout float s) {
	vec3 p = z4.xyz;
	s /= 2.0;

	if (fkochcube_reflection) p.xz = vec2(max(p.x, p.z), min(p.x, p.z));

	if (fkochcube_abs_x) p.x = abs(p.x);
	if (fkochcube_abs_y) p.y = abs(p.y);
	if (fkochcube_abs_z) p.z = abs(p.z);

	if (fkochcube_fold1 == 1) {
		p.yz *= sign(p.y + p.z);
	} else if (fkochcube_fold2 == 2) {
		p.xz -= s;
	} else if (fkochcube_fold2 == 3) {
		p.yz *= sign(p.y + p.z);
		p.xz -= s;
	}

	if (fkochcube_fold2 == 1) p.xz = vec2(max(p.x, p.z), min(p.x, p.z));
	else if (fkochcube_fold2 == 2) p.xz = vec2(min(p.x, p.z), max(p.x, p.z));

	if (!fkochcube_pxyzminuss) p.xz -= s;
	else p -= s;

	p = psort(p, fkochcube_psortsymmetry1);

	if (fkochcube_variant == 2) {
		if (p.x - p.z > 0.0) p.xz = -p.zx;
		if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcube_variant == 1) {
	    if (p.x - p.z > 0.0) p.xz = p.zx;
	} else if (fkochcube_variant == 3) {
	    if (p.x - p.z > 0.0) p.xz = -p.zx;
	} else if (fkochcube_variant == 4) {
	    if (p.x - p.z > 0.0) p.xz = p.zx;
	    if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcube_variant == 5) {
	    if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcube_variant == 6) {
	    if (p.x - p.z > 0.0) p.xz = p.zx;
	    if (p.x < p.y) p.xy = -p.yx;
	} else if (fkochcube_variant == 7) {
	    if (p.x - p.z > 0.0) p.xz = p.zx;
	} else if (fkochcube_variant == 8) {
	    if (p.x - p.z > 0.0) p.xz = -p.zx;
	}

	if (fkochcube_foldzbefore && p.x < p.y) p.xy = -p.yx;

	if (p.x + p.z <= -s){
		p.z += s;
		if (fkochcube_first_zrev) p.xz = -p.zx;
		p.z -= s;
	}

	if (p.y >= p.x + s) {
		if (fkochcube_fold3) p.x += s;
		if (fkochcube_fold4) p.xy = p.yx;
		p.x -= s;
	}

	if (!fkochcube_foldzbefore && p.x < p.y) p.xy = -p.yx;
	p = psort(p, fkochcube_psortsymmetry2);

	s /= 2.0;
	p.xz = abs(p.xz) - s;

	p *= fkochcube_scale;
	dz *= abs(fkochcube_scale);

	z4.xyz = p;

	//s /= 2.0;
	//
	//p = abs(p);
	//p.yz *= sign(p.y + p.z);
	//p.xz -= s;
	//
	//if (p.x + p.z <= -s){
		//p.z += s;
		//p.xz = -p.zx;
		//p.z -= s;
	//}
	//
	//if (p.y >= p.x + s) {
		//p.xy = p.yx;
		//p.x -= s;
	//}
	//
	//if (p.x < p.y) p.xy = -p.yx;
	//
	//s /= 2.0;
	//p.xz = abs(p.xz) - s;
}
//vec2 kochcube_sdf(vec3 p){
    //float s = fkochcube_sphere_inversion ? 0.6 : 1.2;
    //float orbit_trap = 1000.0;
//
    //if (fkochcube_sphere_inversion) p -= fkochcube_sphere_inversion_position;
//
    //float dlength = length(p);
    //float dlength2 = dot(p, p);
//
    //if (fkochcube_sphere_inversion) {
        //p = (fkochcube_sphere_inversion_radius * fkochcube_sphere_inversion_radius / dot(p, p)) * p;
        //p += fkochcube_sphere_inversion_position;
    //}
//
    //for(int i = 0; i < iterations; i++){
		//s /= 2.0;
//
		////p = abs(p);
		////p.xz = vec2(max(p.x, p.z), min(p.x, p.z));
//
		//if (fkochcube_abs_x) p.x = abs(p.x);
		//if (fkochcube_abs_y) p.y = abs(p.y);
		//if (fkochcube_abs_z) p.z = abs(p.z);
//
		//if (fkochcube_fold1 == 1) {
			//p.yz *= sign(p.y + p.z);
		//} else if (fkochcube_fold2 == 2) {
			//p.xz -= s;
		//} else if (fkochcube_fold2 == 3) {
			//p.yz *= sign(p.y + p.z);
			//p.xz -= s;
		//}
//
		//if (fkochcube_fold2 == 1) p.xz = vec2(max(p.x, p.z), min(p.x, p.z));
		//else if (fkochcube_fold2 == 2) p.xz = vec2(min(p.x, p.z), max(p.x, p.z));
//
		//if (!fkochcube_pxyzminuss) p.xz -= s;
		//else p -= s;
//
		//p = psort(p, fkochcube_psortsymmetry1);
//
		//if (fkochcube_variant == 2) {
			//if (p.x - p.z > 0.0) p.xz = -p.zx;
			//if (p.x < p.y) p.xy = -p.yx;
		//} else if (fkochcube_variant == 1) { // vicsek
		    //if (p.x - p.z > 0.0) p.xz = p.zx;
		//} else if (fkochcube_variant == 3) { // vicsek 2
		    //if (p.x - p.z > 0.0) p.xz = -p.zx;
		//} else if (fkochcube_variant == 4) { // mengertetrahedronsnowflake
		    //if (p.x - p.z > 0.0) p.xz = p.zx;
		    //if (p.x < p.y) p.xy = -p.yx;
		//} else if (fkochcube_variant == 5) { // mengertetrahedronsnowflake 2
		    //if (p.x < p.y) p.xy = -p.yx;
		//} else if (fkochcube_variant == 6) { // kochroom (set firstzx = false)
		    //if (p.x - p.z > 0.0) p.xz = p.zx;
		    //if (p.x < p.y) p.xy = -p.yx;
		//} else if (fkochcube_variant == 7) {  // vicsekblockything (set firstzx = false)
		    //if (p.x - p.z > 0.0) p.xz = p.zx;
		//} else if (fkochcube_variant == 8) {
		    //if (p.x - p.z > 0.0) p.xz = -p.zx;
		//}
//
		//if (fkochcube_foldzbefore && p.x < p.y) p.xy = -p.yx;
//
		//if (p.x + p.z <= -s){
			//p.z += s;
			//if (fkochcube_first_zrev) p.xz = -p.zx;
			//p.z -= s;
			//orbit_trap /= 2.0;
		//}
//
		//if (p.y >= p.x + s) {
			//if (fkochcube_fold3) p.x += s; // try variant 1, 3, 4 without this line
			//if (fkochcube_fold4) p.xy = p.yx;  // try variant 2, 5 without this line
			//p.x -= s;
		//}
//
		//if (!fkochcube_foldzbefore && p.x < p.y) p.xy = -p.yx;
		//p = psort(p, fkochcube_psortsymmetry2);
//
		//s /= 2.0;
		//p.xz = abs(p.xz) - s;
//
		////s /= 2.0;
		////
		////p = abs(p);
		////p.yz *= sign(p.y + p.z);
		////p.xz -= s;
		////
		////if (p.x + p.z <= -s){
			////p.z += s;
			////p.xz = -p.zx;
			////p.z -= s;
		////}
		////
		////if (p.y >= p.x + s) {
			////p.xy = p.yx;
			////p.x -= s;
		////}
		////
		////if (p.x < p.y) p.xy = -p.yx;
		////
		////s /= 2.0;
		////p.xz = abs(p.xz) - s;
//
		//if (coloring_mode == 0 && i > color_min_iterations && i < color_max_iterations) orbit_trap = min(orbit_trap, length(s * p));
		//else orbit_trap = min(orbit_trap, process_orbit_trap(p, i));
    //}
//
    //float d = cube_sdf3d(p, vec3(s));//length(p);
//
    //return vec2(d, orbit_trap);
//}