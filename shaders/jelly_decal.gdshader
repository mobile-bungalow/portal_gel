shader_type spatial;

// Use unshaded rendering mode with depth test disabled and front-face culling
render_mode depth_test_disabled;

// Uniforms for depth texture, position texture, noise texture, and number of decals
uniform sampler2D depth_tex : hint_depth_texture;
uniform sampler2D position_tex;
uniform sampler2D noise;
uniform int num_decals;
const float k = 0.5;

// Function to transform point from global to model space
vec3 transformPointToModelSpace(vec3 point, mat4 model_matrix) {
    return (model_matrix * vec4(point, 1.0)).xyz;
}

float opSmoothUnion(float d1, float d2) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// Function to generate a pseudo-random value based on 2D coordinates
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}
void fragment() {
    // Retrieve depth information from the depth texture
    float depth = textureLod(depth_tex, SCREEN_UV, 0.0).r;

    // Transform screen coordinates to world coordinates
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    vec4 wpos = INV_VIEW_MATRIX * (upos / upos.w);

    // Transform world coordinates to object coordinates
    vec3 obj_position = (inverse(MODEL_MATRIX) * wpos).xyz;

    float circle_radius = 0.3; // Set the radius of the circle

    float d = 1000.0;

    for (int i = 0; i < num_decals; i++) {
        vec4 particle = texelFetch(position_tex, ivec2(i, 0), 0);
        vec3 particlePos = transformPointToModelSpace(particle.rgb, inverse(MODEL_MATRIX));
        
		float timestamp_offset =  TIME - particle.a;
        float max_radius_increase = 0.3; // Adjust the maximum radius increase as needed
        float animated_radius = circle_radius + min(0.3 * timestamp_offset, 0.3);
        // Include particle position in ray marching with offset
		// TODO: find out what this offset actually should be
        d = opSmoothUnion(d, length(obj_position.xz - particle.xz + vec2(2.5, 0.0)) - animated_radius);
    }

    // Use noise texture to feather out the edges
    float noise_value = texture(noise, obj_position.xz * 0.1).r; // Adjust the scale as needed
    float feather_distance = 0.05; // Adjust the feather distance as needed
    
    // Threshold the distance against the noise to feather out the edges
    float thresholded_distance = smoothstep(circle_radius - feather_distance, circle_radius, d * noise_value);

    // Check if the fragment is outside the feathered circle
    if (thresholded_distance > 0.0) {
        discard;
    }

    float alpha = 0.9;

    // Set the color of the circles
    NORMAL = vec3(noise_value * 0.15, 1.0, noise_value * 0.15);
    ALBEDO.xyz = vec3(0.0, 0.1, 0.55);
	METALLIC = 0.3;
	SPECULAR = 0.3;
	ROUGHNESS = 0.4;
    ALPHA = clamp(alpha, 0.0, 1.0);
}