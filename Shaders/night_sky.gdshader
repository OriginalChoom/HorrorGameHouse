shader_type sky;

// --- Sky gradient ---
uniform vec3 zenith_color : source_color = vec3(0.004, 0.008, 0.02);
uniform vec3 horizon_color : source_color = vec3(0.015, 0.03, 0.06);
uniform vec3 ground_color : source_color = vec3(0.003, 0.005, 0.01);
uniform float gradient_power : hint_range(0.1, 2.0) = 0.4;

// --- Stars ---
uniform float star_scale = 90.0;                          // higher = smaller, more numerous cells
uniform float star_amount : hint_range(0.0, 0.5) = 0.06;  // fraction of cells that contain a star
uniform float star_size : hint_range(0.05, 0.5) = 0.2;
uniform float star_brightness = 1.5;

// --- Moon (drawn where the DirectionalLight3D is) ---
// Equirectangular moon map (2:1), centered on 0 degrees longitude.
// Enable Mipmaps > Generate in the Import dock for this texture.
// Left empty, the moon is a plain white disc.
uniform sampler2D moon_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform vec3 moon_color : source_color = vec3(0.85, 0.9, 1.0);  // tint multiplied with the texture
uniform float moon_radius = 0.06;      // radians; big enough that the surface detail reads
uniform float moon_brightness = 6.0;   // moon maps are dark, so this is high; above 1.0 also feeds glow
uniform float moon_rotation : hint_range(-3.1416, 3.1416) = 0.0;  // spin the moon face
uniform float halo_size = 0.12;
uniform float halo_strength = 0.25;

float hash13(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.zyx + 31.32);
	return fract((p.x + p.y) * p.z);
}

float star_field(vec3 dir) {
	vec3 p = dir * star_scale;
	vec3 cell = floor(p);
	vec3 local = fract(p);
	if (hash13(cell) > star_amount) {
		return 0.0;
	}
	vec3 offset = vec3(hash13(cell + 13.1), hash13(cell + 27.7), hash13(cell + 41.3));
	float d = distance(local, 0.2 + 0.6 * offset);
	float size = star_size * (0.4 + 0.6 * hash13(cell + 5.9));
	return 1.0 - smoothstep(0.0, size, d);
}

void sky() {
	vec3 dir = EYEDIR;

	// Base gradient
	float g = pow(clamp(dir.y, 0.0, 1.0), gradient_power);
	vec3 col = mix(horizon_color, zenith_color, g);
	float below = 1.0 - smoothstep(-0.05, 0.0, dir.y);
	col = mix(col, ground_color, below);

	// Skip stars and moon when the sky is captured for ambient/reflections,
	// so they don't add extra light to the scene.
	if (!AT_CUBEMAP_PASS) {
		float above = smoothstep(0.0, 0.2, dir.y);
		float stars = star_field(dir) * star_brightness * above;
		vec3 moon_light = vec3(0.0);

		if (LIGHT0_ENABLED) {
			vec3 moon_dir = LIGHT0_DIRECTION;
			float ang = acos(clamp(dot(dir, moon_dir), -1.0, 1.0));
			float disc = 1.0 - smoothstep(moon_radius * 0.95, moon_radius, ang);
			float halo = exp(-ang / halo_size) * halo_strength;

			// Local frame facing the viewer, with the moon's "north" pointing up.
			vec3 ref_up = abs(moon_dir.y) > 0.99 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);
			vec3 right = normalize(cross(moon_dir, ref_up));
			vec3 up = cross(right, moon_dir);

			// Position on the disc in [-1, 1], optionally rotated.
			vec2 p = vec2(dot(dir, right), dot(dir, up)) / sin(moon_radius);
			float cs = cos(moon_rotation);
			float sn = sin(moon_rotation);
			p = vec2(cs * p.x - sn * p.y, sn * p.x + cs * p.y);

			// Treat the disc as a sphere and look up the equirectangular map.
			float r2 = clamp(dot(p, p), 0.0, 1.0);
			vec3 n = vec3(p, sqrt(1.0 - r2));
			vec2 uv = vec2(atan(n.x, n.z) / TAU + 0.5, 0.5 - asin(clamp(n.y, -1.0, 1.0)) / PI);
			vec3 tex = texture(moon_texture, uv).rgb;

			stars *= 1.0 - clamp(disc + halo * 4.0, 0.0, 1.0);
			moon_light = moon_color * (tex * moon_brightness * disc + halo);
		}

		col += vec3(stars) + moon_light;
	}

	COLOR = col;
}
