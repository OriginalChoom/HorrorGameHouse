shader_type spatial;

// Hides texture repetition while keeping the full PBR set:
//  - Albedo
//  - ORM packed map: AO = red, Roughness = green, Metallic = blue
//  - Normal map
//
// Two modes (slab_aware):
//  OFF - stochastic blend: every texture repeat gets a random offset and
//        neighbours are crossfaded. Good for organic / noisy textures
//        (mosaics, dirt, rock). Bad for textures with straight grout lines,
//        because the offset copies don't line up and lines look doubled.
//  ON  - slab mode: for textures made of whole slabs/tiles with grout lines.
//        Every slab on the floor shows a random slab from the texture, cut at
//        the grout lines with NO blending, so grout stays perfectly straight.
//        Each slab also gets its own small brightness variation.
//
// All maps use the same offsets, so they always stay aligned with each other.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 albedo_tint : source_color = vec4(1.0);
uniform sampler2D orm_tex : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;

uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float specular : hint_range(0.0, 1.0) = 0.5;
uniform float ao_light_affect : hint_range(0.0, 1.0) = 0.0;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;

// Repeats per world unit (metre) when use_world_space is on,
// repeats per UV unit when it's off.
uniform float uv_scale = 0.5;
uniform bool use_world_space = true;

// --- Slab mode ---
uniform bool slab_aware = true;
// How many WHOLE slabs fit across one repeat of the texture (X, Y).
// Count them in your texture. The texture edges must fall on grout lines.
uniform vec2 slabs_per_tile = vec2(2.0, 2.0);
// Random brightness change per slab (0 = none).
uniform float slab_tone_variation : hint_range(0.0, 1.0) = 0.15;

// --- Macro variation ---
// Assign a NoiseTexture2D (Seamless = on), then raise macro_strength.
uniform sampler2D macro_noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float macro_scale = 0.05;
uniform float macro_strength : hint_range(0.0, 1.0) = 0.0;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

vec2 hash22(vec2 p) {
	vec2 q = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(q) * 43758.5453);
}

// Blend mode: random offset per repeat, crossfaded.
vec4 sample_blend(sampler2D tex, vec2 uv, vec2 ddx, vec2 ddy) {
	vec2 cell = floor(uv);
	vec2 f = fract(uv);
	// Narrower range = crisper texture but a more visible transition.
	vec2 w = smoothstep(0.25, 0.75, f);

	vec4 a = textureGrad(tex, uv + hash22(cell + vec2(0.0, 0.0)), ddx, ddy);
	vec4 b = textureGrad(tex, uv + hash22(cell + vec2(1.0, 0.0)), ddx, ddy);
	vec4 c = textureGrad(tex, uv + hash22(cell + vec2(0.0, 1.0)), ddx, ddy);
	vec4 d = textureGrad(tex, uv + hash22(cell + vec2(1.0, 1.0)), ddx, ddy);

	return mix(mix(a, b, w.x), mix(c, d, w.x), w.y);
}

// Slab mode: each world slab shows a random slab of the texture. The offset is
// a whole number of slabs, so slab borders always land on the texture's grout.
vec4 sample_slabs(sampler2D tex, vec2 uv, vec2 ddx, vec2 ddy) {
	vec2 slab_id = floor(uv * slabs_per_tile);
	vec2 off = floor(hash22(slab_id) * slabs_per_tile) / slabs_per_tile;
	return textureGrad(tex, uv + off, ddx, ddy);
}

vec4 sample_map(sampler2D tex, vec2 uv, vec2 ddx, vec2 ddy) {
	if (slab_aware) {
		return sample_slabs(tex, uv, ddx, ddy);
	}
	return sample_blend(tex, uv, ddx, ddy);
}

void fragment() {
	vec2 uv = (use_world_space ? world_pos.xz : UV) * uv_scale;
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);

	// Albedo
	vec3 albedo = sample_map(albedo_tex, uv, ddx, ddy).rgb * albedo_tint.rgb;

	// Per-slab brightness variation
	if (slab_aware) {
		float tone = hash22(floor(uv * slabs_per_tile) + vec2(17.0, 43.0)).x;
		albedo *= 1.0 + (tone - 0.5) * 2.0 * slab_tone_variation;
	}

	// Macro variation
	float n = texture(macro_noise, world_pos.xz * macro_scale).r;
	albedo *= 1.0 + (n - 0.5) * 2.0 * macro_strength;

	// ORM: R = AO, G = roughness, B = metallic
	vec3 orm = sample_map(orm_tex, uv, ddx, ddy).rgb;

	ALBEDO = albedo;
	AO = orm.r;
	AO_LIGHT_AFFECT = ao_light_affect;
	ROUGHNESS = orm.g * roughness;
	METALLIC = orm.b * metallic;
	SPECULAR = specular;

	NORMAL_MAP = sample_map(normal_tex, uv, ddx, ddy).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
}
