// [ID]
// kochcube
// [INDEX]
// 14
// [VARS]
// int variant[0, 10] = 0
// bool first_zrev[false, true] = true
// bool pxyzminuss[false, true] = true
// bool psortsymmetry1[false, true] = false
// bool psortsymmetry2[false, true] = false
// bool foldzbefore[false, true] = true
// bool sphere_inversion[false, true] = false
// vec3 sphere_inversion_position[(-2, -2, -2), (2, 2, 2)] = (1, 0, 0)
// float sphere_inversion_radius[0, 2] = 1
// [CODE]
uniform int  fkochcube_variant = 0;
uniform bool fkochcube_first_zrev = true;
uniform bool fkochcube_pxyzminuss = false;
uniform bool fkochcube_psortsymmetry1 = false;
uniform bool fkochcube_psortsymmetry2 = false;
uniform bool fkochcube_foldzbefore = true;
uniform bool fkochcube_sphere_inversion = false;
uniform vec3 fkochcube_sphere_inversion_position = vec3(1.0, 0, 0);
uniform float fkochcube_sphere_inversion_radius = 1.0;

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

vec2 kochcube_sdf(vec3 p){
    float s = fkochcube_sphere_inversion ? 0.6 : 1.2;
    float orbit_trap = 1000.0;

    if (fkochcube_sphere_inversion) p -= fkochcube_sphere_inversion_position;

    float dlength = length(p);
    float dlength2 = dot(p, p);

    if (fkochcube_sphere_inversion) {
        p = (fkochcube_sphere_inversion_radius * fkochcube_sphere_inversion_radius / dot(p, p)) * p;
        p += fkochcube_sphere_inversion_position;
    }

    for(int i = 0; i < iterations; i++){
        s /= 2.0;

        //p.xz *= Rot(3.14159 / 4.0);  try different places

        //optional i think: //p.y*=sign(p.x*p.z);
        //p = abs(p);
        //p.xz = vec2(max(p.x, p.z), min(p.x, p.z));

        //p.xz = abs(p.xz);
        p = abs(p);

        //p.xz = vec2(min(p.x, p.z), max(p.x, p.z));

        //optional i think: p.yz *= sign(p.y + p.z);
        if (!fkochcube_pxyzminuss) p.xz -= s;
        else p -= s;

        p = psort(p, fkochcube_psortsymmetry1);

        if (fkochcube_variant == 2) {
            if (p.x - p.z > 0.0) p.xz = -p.zx;
            if (p.x < p.y) p.xy = -p.yx;
        } else if (fkochcube_variant == 1) { // vicsek
            if (p.x - p.z > 0.0) p.xz = p.zx;
        } else if (fkochcube_variant == 3) { // vicsek 2
            if (p.x - p.z > 0.0) p.xz = -p.zx;
        } else if (fkochcube_variant == 4) { // mengertetrahedronsnowflake
            if (p.x - p.z > 0.0) p.xz = p.zx;
            if (p.x < p.y) p.xy = -p.yx;
        } else if (fkochcube_variant == 5) { // mengertetrahedronsnowflake 2
            if (p.x < p.y) p.xy = -p.yx;
        } else if (fkochcube_variant == 6) { // kochroom (set firstzx = false)
            if (p.x - p.z > 0.0) p.xz = p.zx;
            if (p.x < p.y) p.xy = -p.yx;
        } else if (fkochcube_variant == 7) {  // vicsekblockything (set firstzx = false)
            if (p.x - p.z > 0.0) p.xz = p.zx;
        } else if (fkochcube_variant == 8) {
            if (p.x - p.z > 0.0) p.xz = -p.zx;
        }

        if (fkochcube_foldzbefore && p.x < p.y) p.xy = -p.yx;

        if (p.x + p.z <= -s){
            p.z += s;
            if (fkochcube_first_zrev) p.xz = -p.zx;
            p.z -= s;
			orbit_trap /= 2.0;
        }

        if (p.y >= p.x + s) {
            p.x += s; // try variant 1, 3, 4 without this line
            p.xy = p.yx;  // try variant 2, 5 without this line
            p.x -= s;
        }

        if (!fkochcube_foldzbefore && p.x < p.y) p.xy = -p.yx;
        p = psort(p, fkochcube_psortsymmetry2);

        s /= 2.0;
        p.xz = abs(p.xz) - s;

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

        if (coloring_mode == 0) orbit_trap = min(orbit_trap, length(s * p));
		else orbit_trap = min(orbit_trap, process_orbit_trap(p));
    }

    float d = cube_sdf3d(p, vec3(s));//length(p);
    if (fkochcube_sphere_inversion) d = d * dlength2 / (fkochcube_sphere_inversion_radius + dlength * d);

    return vec2(d, orbit_trap);
}