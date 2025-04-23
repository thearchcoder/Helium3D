// [ID]
// Spheretree
// [INDEX]
// 12
// [VARS]
// float symmetry[1, 100] = 1
// [CODE]
uniform float fspheretree_symmetry;

vec2 spheretree_sdf(vec3 p) {
	p /= 3.0;
	p.z += 0.5;
	float rad = 0.2;
	vec3 s0 = vec3(0.0,1.0,rad);
	vec3 s1 = vec3(sqrt(3.0)/2.0, -0.5,rad);
	vec3 s2 = vec3(-sqrt(3.0)/2.0, -0.5,rad);
	vec3 t0 = vec3(0.0,1.0,0.0);
	vec3 t1 = vec3(sqrt(3.0)/2.0, -0.5,0.0);
	vec3 t2 = vec3(-sqrt(3.0)/2.0, -0.5,0.0);
	vec3 n0 = vec3(1.0,0.0,0.0);
	vec3 n1 = vec3(-0.5, -sqrt(3.0)/2.0,0.0);
	vec3 n2 = vec3(-0.5, sqrt(3.0)/2.0,0.0);
	float orbit_trap = 100000.0;
	float scale = 0.45;

	float innerScale = sqrt(3.0)/(1.0 + sqrt(3.0));
	for (int i = 0; i < iterations; i++) {
        float angle = 3.14159265 / fspheretree_symmetry;
        float theta = atan(p.y, p.x);
        float r = length(p.xy);
        theta = mod(theta + angle, 2.0 * angle) - angle;
        p.xy = vec2(cos(theta), sin(theta)) * r;

        if (length(p-vec3(0,0,innerScale*0.5)) < innerScale*0.5)
          break; // definitely inside
        float maxH = 0.4;
        if (i==0)
          maxH = -100.0;
        if (p.z > maxH && length(p-vec3(0,0,0.5*1.1)) > 0.5*1.1)
          break; // definitely outside
        if (p.z < maxH && length(p -vec3(0,0,0.5)) > 0.5)
        {
          // needs a sphere inverse
          float sc =  dot(p,p);
          scale *= sc;
          p /= sc;
        }
        else
        {
          // stretch onto a plane at zero
          scale *= dot(p, p);
          p /= dot(p, p);
          p.z -= 1.0;
          p.z *= -1.0;
          p *= sqrt(3.0);
          scale /= sqrt(3.0);
          p.z += 1.0;

          // and rotate it a twelfth of a revolution
          float a = 3.1415/6.0;
          float xx = p.x*cos(a) + p.y*sin(a);
          float yy = -p.x*sin(a) + p.y*cos(a);
          p.x = xx;
          p.y = yy;
        }
        // now modolu the space so we move to being in just the central hexagon, inner radius 0.5
        float h = p.z;
        float x = dot(p, -n2) * 2.0/sqrt(3.0);
        float y = dot(p, -n1) * 2.0/sqrt(3.0);
        x = mod(x, 1.0);
        y = mod(y, 1.0);
        if (x + y > 1.0)
        {
          x = 1.0-x;
          y = 1.0-y;
        }
        p = x*t1 - y*t2;

        // fold the space to be in a kite
        float l0 = dot(p,p);
        float l1 = dot(p-t1, p-t1);
        float l2 = dot(p+t2,p+t2);
        if (l1 < l0 && l1 < l2)
          p -= t1 * (2.0*dot(t1, p) - 1.0);
        else if (l2 < l0 && l2 < l1)
          p -= t2 * (2.0 * dot(p, t2) + 1.0);
        p.z = h;

        //if (p.y < p.z) p.yz = p.zy;

        //if (p.x > p.y) p.xy = p.yx;
        //if (p.x > p.z) p.xz = p.zx;
        //if (p.y > p.z) p.yz = p.zy;
        //if (p.x > p.y) p.xy = p.yx;
        //if (p.x > p.z) p.xz = p.zx;
        //if (p.y > p.z) p.yz = p.zy;

        //p += min(p, vec3(0.0)) * 2.3;

        // (spiral fold)

        //p *= 1.3;

        //p *= 0.95;

        //float n = 100.0; // Number of symmetry planes
        //float angle = 3.14159265 / n;
        //float theta = atan(p.y, p.x);
        //float r = length(p.xy);
        //theta = mod(theta + angle, 2.0 * angle) - angle;
        //p.xy = vec2(cos(theta), sin(theta)) * r;
		if (coloring_mode == 0) orbit_trap = min(orbit_trap, dot(p, p));
		else orbit_trap = min(orbit_trap, process_orbit_trap(p));
    }

    float d = (length(p-vec3(0,0,0.4)) - 0.4) * scale; // the 0.4 is slightly more averaging than 0.5

    return vec2(d, orbit_trap);
}