// [ID]
// Romanesco Broccoli Dupe F
// [OFFICIAL]
// [PRIMITIVE]
// [VARS]
// [CODE]
const uint romanescobroccolidupef_k = 1103515245U;
vec3 romanescobroccolidupef_hash(uvec3 x) {
	x = ((x>>8U)^x.yzx)*romanescobroccolidupef_k;
	x = ((x>>8U)^x.yzx)*romanescobroccolidupef_k;
	x = ((x>>8U)^x.yzx)*romanescobroccolidupef_k;
	return vec3(x)*(1.0/float(0xffffffffU));
}

vec2 romanescobroccolidupef_polar_rep(in vec2 p, in float n) {
	n = PI*0.5/n;
	float a = atan(p.y, p.x);
	float r = length(p);
	a = mod(a + n/2.0, n) - n/2.0;
	p = r * vec2(cos(a), sin(a));
	return 0.5 * (p+p-vec2(1,0));
}

float romanescobroccolidupef_sd_box(in vec2 p, in vec2 b) {
	vec2 d = abs(p) - b;
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec3 romanescobroccolidupef_inverse_sf(in vec3 p, const in float n) {
	float m = 1.0-1.0/n;
	float phi = min(atan(p.y,p.x),PI);
	float k = max(2.,floor(log(n*PI*sqrt(5.)*(1.-p.z*p.z))/log(PHI+1.)));
	float Fk = pow(PHI,k)/sqrt(5.0);
	vec2 F = vec2(round(Fk),round(Fk*PHI));
	vec2 ka = 2.0*F/n;
	vec2 kb = 2.0*PI*(fract((F+1.0)*PHI)-(PHI-1.0));
	mat2 iB = mat2(vec2(ka.y,-ka.x),vec2(kb.y,-kb.x))/(ka.y*kb.x-ka.x*kb.y);
	vec2 c = floor(iB*vec2(phi,p.z-m));
	float d = 8.0;
	vec3 res = vec3(0);
	for(int s = 0; s < 4; s++) {
		vec2 uv = vec2(float(s-2*(s/2)),float(s/2));
		float i = dot(F,uv+c);
		float phi = 2.0*PI*fract(i*PHI);
		float cT = m-2.0*i/n;
		float sT = sqrt(1.0-cT*cT);
		vec3 q = vec3(cos(phi)*sT, sin(phi)*sT,cT);
		float sqDist = dot(q-p,q-p);
		if (sqDist < d) {
			d = sqDist;
			res = q;
		}
	}
	return res;
}

vec2 romanescobroccolidupef_remap(in vec2 p) {
	float sig = p.x > 0.0 ? +1.0: -1.0;
	p.x = abs(p.x);
	float theta = 0.0;
	float radius = 0.0;
	
	float botPos = atan(p.x, -p.y) / (PI*0.5+CONE_THETA);
	if (botPos < 1.0) {
		theta = (botPos * CONE_LBOT) / CONE_L;
		radius = length(p);
	} else {
		float pos = dot(p, CONE_CSLOPE);
		float flatPos = pos / CONE_LFLAT;
		if (flatPos < 1.0) {
			theta = (CONE_LBOT + flatPos*CONE_LFLAT) / CONE_L;
			radius = dot(p, CONE_SLOPE);
		} else {
			p.y -= CONE_HEIGHT;
			float topPos = (atan(p.y, p.x) - CONE_THETA) / (PI*0.5-CONE_THETA);
			theta = (CONE_LBOT + CONE_LFLAT + topPos*CONE_LTOP) / CONE_L;
			radius = length(p) + (1.0 - CONE_RADIUS);
		}
	}
	
	theta *= theta;
	theta = theta * sig * PI;
	return vec2(sin(theta), -cos(theta))*radius;
}

vec3 romanescobroccolidupef_deform(in vec3 p) {
	vec2 dir = p.xy;
	float dirLen = length(dir);
	vec2 cyl = vec2(dirLen, -p.z);
	cyl = romanescobroccolidupef_remap(cyl);
	return vec3(dir/dirLen*cyl.x, cyl.y);
}

vec2 romanescobroccolidupef_sdf(vec4 p4d) {
	vec3 p = p4d.xyz;
	p.z = -p.z;
	vec3 pp = p;
	p = romanescobroccolidupef_deform(p);
	
	float orbit_trap = 1.0;
	float de = length(p)-1.0;
	float s = 1.0;
	
	const int FRACTAL_LEVELS = 2;
	const float FIBO_COUNT = 100.0;
	
	for (int i = 0; i < FRACTAL_LEVELS; i++) {
		float f = smoothstep(-1.0, 1.5, p.z);
		vec3 onSurf = romanescobroccolidupef_inverse_sf(normalize(p), FIBO_COUNT);
		p -= onSurf;
		
		vec3 t = normalize(cross(onSurf, vec3(0, 0, 1)));
		vec3 ct = cross(onSurf, t);
		p = vec3(dot(p, t), dot(p, ct), -dot(p, onSurf));
		
		float scale = mix(3.0, 7.0, f);
		p *= scale;
		p.xy *= mix(1.5, 1.0, f);
		p = romanescobroccolidupef_deform(p);
		
		s *= scale;
		float deNew = (length(p)-1.0)/s;
		
		orbit_trap = min(orbit_trap, dot(p, p) * sin(p.y));
		de = smin_force_no_exp(de, deNew, 0.1);
	}
	
	return vec2(de, orbit_trap);
}