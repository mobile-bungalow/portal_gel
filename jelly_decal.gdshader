shader_type spatial;

// Use unshaded rendering mode with depth test disabled and front-face culling

render_mode depth_test_disabled;

// Uniforms for depth texture, position texture, noise texture, and number of decals
uniform sampler2D depth_tex : hint_depth_texture;
uniform sampler2D position_tex;
uniform sampler2D noise;
uniform int num_decals;

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
    vec3 obj_position = -(inverse(MODEL_MATRIX) * wpos).xyz;
    
    float circle_radius = 0.4; // Set the radius of the circle
    
    // Check if the fragment is outside the circle
    if (length(obj_position.xz) > circle_radius) {
        discard;
    }
    
    float alpha = 0.5;

    
    // Calculate the specular reflection component
    vec3 view_dir = normalize(VIEW - wpos.xyz);
    vec3 normal = normalize(cross(dFdx(obj_position), dFdy(obj_position)));

    
    // Set the color of the circle with specular reflection
	NORMAL = vec3(0.0, 1.0, 0.0);
    ALBEDO.xyz = vec3(1.0, 0.0, 0.0);
	SPECULAR = 1.0;
	ROUGHNESS = 1.0;
	METALLIC = 1.0;
    ALPHA = 1.0; //clamp(alpha, 0.0, 1.0);
}