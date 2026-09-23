shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 primary_color : source_color;
uniform vec4 secondary_color : source_color;

uniform float roughness = 0.2;

uniform sampler2D normalmap_a : hint_normal;
uniform sampler2D normalmap_b : hint_normal;

uniform float normalmap_a_strenght : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float normalmap_b_strenght : hint_range(0.0, 1.0, 0.01) = 0.25;

uniform vec2 movement_direction = vec2(0.2, 0.1);
uniform float movement_strenght = 0.12;

uniform float uv_scale = 1.0;

// Depth
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform float depth_distance : hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float beers_law : hint_range(0.0, 20.0, 0.1) = 12.0;
uniform float water_transparancy : hint_range(0.0, 1.0, 0.01) = 0.0;

//refracion
uniform float refraction_strenght : hint_range(0.0, 8.0, 0.001) = 0.5;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow(
		1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0),
		amount
	);
}

void vertex() {

}

void fragment() {

	// Fresnel
	float basic_fresnel = fresnel(3.0, NORMAL, VIEW);

	// UV movement
	vec2 uv = UV * uv_scale;
	vec2 uv_movement = movement_direction * TIME * movement_strenght;

	// Normal maps
	vec3 normalmap =
		texture(normalmap_a, uv + uv_movement).rgb
		* normalmap_a_strenght;

	normalmap +=
		texture(normalmap_b, uv - uv_movement).rgb
		* normalmap_b_strenght;
		
	vec3 ref_normalmap = normalmap * 2.0 - (normalmap_a_strenght + normalmap_b_strenght);
	vec3 ref_normal = mix(NORMAL, TANGENT * ref_normalmap + BINORMAL * ref_normalmap + NORMAL * ref_normalmap, 1.0);
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction_strenght;

	NORMAL_MAP = normalmap;

	// Depth texture
	float depth_clean = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	float depth = textureLod(depth_texture, ref_ofs, 0.0).r;
	vec3 screen = textureLod(screen_texture, ref_ofs, 0.0).rgb;
	

	// World reconstruction
	vec3 ndc = vec3(
		SCREEN_UV * 2.0 - 1.0,
		depth
	);
	vec3 ndc_clean = vec3(SCREEN_UV * 2.0 - 1.0, depth_clean);
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z + VERTEX.z;

	vec4 world;
	
	if (linear_depth < 0.00001){
		world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc_clean, 1.0);
	}
	else{
		world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	}
	
	float depth_texture_y = world.y / world.w;

	float vertex_y =
		(INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;

	// Depth blend
	float depth_blend = clamp(
		(vertex_y - depth_texture_y) / depth_distance,
		0.0,
		1.0
	);

	depth_blend = exp(-depth_blend * beers_law);

	// Water color
	vec3 depth_color =
		mix(
			secondary_color.rgb,
			primary_color.rgb,
			depth_blend
		);
		
	vec3 refraction_texture;
	if(linear_depth < 0.00001){
		refraction_texture = textureLod(screen_texture, SCREEN_UV, ROUGHNESS * 2.0).rgb;
	}
	else{
		refraction_texture = textureLod(screen_texture, ref_ofs, ROUGHNESS * 2.0).rgb;
	}
	
	vec3 final_color = mix(depth_color, refraction_texture, water_transparancy * depth_blend);
	
	// Final material
	ALBEDO = final_color;

	ALPHA =
		water_transparancy
		+ (basic_fresnel * 0.25);

	ROUGHNESS = clamp(
		roughness - basic_fresnel * 0.1,
		0.01,
		1.0
	);
}
