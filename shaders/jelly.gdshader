shader_type spatial;
//render_mode unshaded;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D particles;
uniform int n_particles;

uniform float radius = 0.2;
uniform float k = 0.3;
uniform vec3 color: source_color = vec3(0.0);
varying vec3 world_camera;
varying vec3 world_position;

const int MAX_STEPS = 32;
const float MAX_DIST = 100.0;
const float SURF_DIST = 1e-2;


float opSmoothUnion(float d1, float d2) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// Function to transform point from global to model space
vec3 transformPointToModelSpace(vec3 point, mat4 model_matrix) {
    return (model_matrix * vec4(point, 1.0)).xyz;
}

vec3 hash3( uint n ) 
{
    // integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
    n = n * (n * n * 15731U + 789221U) + 1376312589U;
    uvec3 ka = n * uvec3(n,n*16807U,n*48271U);
    return vec3( ka & uvec3(0x7fffffffU))/float(0x7fffffff);
}


float displacement(float seed_in, vec3 p) {
	float frequency = 45.0;
	float damping_factor = 0.03;
	float speed = (TIME * 4.2);
	vec3 dim_factor = vec3(0.21, 0.23, 0.15);
	vec3 world_wave = cos(p * dim_factor * frequency + speed);  
	return length(world_wave + hash3(uint(seed_in))) * damping_factor;
}


float GetDist(vec3 p, vec4 point1, vec4 point2, vec4 point3, mat4 m) {
   float d = 100000.0;

 	for (int i = 0; i < n_particles; i++) {
        vec4 particle = texelFetch(particles, ivec2(i, 0), 0);
        vec3 particlePos = transformPointToModelSpace(particle.rgb, inverse(m));
        // Include particle position in ray marching
        d = opSmoothUnion(d, length(p - particlePos) - radius);
    }

	return d + displacement(0x1337, p);
}

float RayMarch(vec3 ro, vec3 rd, vec4 point1, vec4 point2, vec4 point3, mat4 m) {
    float dO = 0.0;
    float dS;

    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + dO * rd;
        dS = GetDist(p, point1, point2, point3, m);
        dO += dS;

        if (dS < SURF_DIST || dO > MAX_DIST)
            break;
    }
    return dO;
}


vec3 GetNormal(vec3 p, vec4 point1, vec4 point2, vec4 point3, mat4 m) {
    vec2 e = vec2(1e-3, 0);

    vec3 n = GetDist(p, point1, point2, point3, m) - vec3(
        GetDist(p - e.xyy, point1, point2, point3, m),
        GetDist(p - e.yxy, point1, point2, point3, m),
        GetDist(p - e.yyx, point1, point2, point3, m)
    );

    return normalize(n);
}

void vertex() {
    world_position = VERTEX;
    world_camera = (inverse(MODELVIEW_MATRIX) * vec4(0, 0, 0, 1)).xyz; // object space
}

void fragment() {
	// Ray Direction
    vec3 rd = normalize(world_position - world_camera);

	float d = RayMarch(world_camera, rd, vec4(0.0), vec4(0.0), vec4(0.0), MODEL_MATRIX);
    
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  	view.xyz /= view.w;
  	float linear_depth = -view.z;
		
    if (d >= MAX_DIST || d > linear_depth) {
		discard;
	} else {
        vec3 p = world_camera + rd * d;
        vec3 n = GetNormal(p, vec4(0.0), vec4(0.0), vec4(0.0), MODEL_MATRIX);
        ALBEDO = color;
		NORMAL = n.rgb;
		METALLIC = 0.6;
		SPECULAR = 0.4;
		ROUGHNESS = 0.1;
    }
}