shader_type spatial;
render_mode cull_disabled, alpha_to_coverage, diffuse_burley, specular_schlick_ggx;

// --- Textures ---
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 albedo_tint : source_color = vec4(1.0);
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;
// NOTE: alpha_to_coverage above is the "Alpha Edge Blend" antialiasing mode for
// alpha-scissor edges. It only has a visible effect if Project Settings >
// Rendering > Anti-Aliasing > MSAA 3D is set to 4x or higher.

// --- Wind ---
// Vertex color convention: this tree's baked-in vertex paint uses the GREEN
// channel as the wind weight (0.0 at the trunk / branch base, 1.0 at the tips).
// If green doesn't produce the right movement, try COLOR.b instead below —
// some tree generators (e.g. Tree It) use blue for this instead of green.
uniform vec2 wind_direction = vec2(1.0, 0.4);               // XZ direction, any length works
uniform float wind_speed : hint_range(0.0, 5.0) = 1.1;
uniform float gust_speed : hint_range(0.0, 5.0) = 2.6;
// Start small and dial up — see the tuning steps. These are intentionally
// conservative defaults since the right value depends on your mesh's local scale.
uniform float wind_strength : hint_range(0.0, 1.0) = 0.03;
uniform float gust_strength : hint_range(0.0, 1.0) = 0.02;
uniform float wind_scale : hint_range(0.0, 2.0) = 1.0;       // master knob; 0 = no wind at all

// --- Debug ---
// Off: normal rendering.
// Raw Vertex Color: shows COLOR.rgb exactly as-is — compare this directly
//   against what Blender's Vertex Paint viewport shows. If this comes out as
//   one flat, uniform color instead of the mottled pattern from Blender, the
//   vertex color data itself isn't reaching this mesh in Godot at all.
// Wind Weight: shows just the channel used for wind, as grayscale.
uniform int debug_mode : hint_enum("Off", "Raw Vertex Color", "Wind Weight") = 0;

varying float v_wind_weight;

void vertex() {
	float wind_weight = COLOR.g;
	v_wind_weight = wind_weight;

	// MODEL_MATRIX is the per-instance transform inside vertex(), even for a
	// MultiMesh, so each tree gets its own phase and they don't sway in sync.
	vec3 world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float phase = dot(world_pos.xz, vec2(12.9898, 78.233));

	float base = sin(TIME * wind_speed + phase);
	float gust = sin(TIME * gust_speed + phase * 1.7) * sin(TIME * wind_speed * 0.35 + phase);
	float sway = (base * wind_strength + gust * gust_strength) * wind_scale;

	vec2 dir = normalize(wind_direction);
	VERTEX.x += dir.x * sway * wind_weight;
	VERTEX.z += dir.y * sway * wind_weight;
}

void fragment() {
	if (debug_mode == 1) {
		ALBEDO = COLOR.rgb;
		ALPHA = 1.0;
	}
	if (debug_mode == 2) {
		ALBEDO = vec3(v_wind_weight);
		ALPHA = 1.0;
	}

	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb * albedo_tint.rgb;
	ALPHA = tex.a * albedo_tint.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}
