shader_type canvas_item;

uniform float dissolve : hint_range(0.0, 1.0) = 0;

// I have no idea where this came from or how it works. All I know is that a
// bunch of other shaders use it.
float random_alpha(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 438.5453);
}

void fragment() {
	vec2 texture_resolution = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel_within_texture = floor(UV * texture_resolution);
	vec4 texture_color = texture(TEXTURE, UV);
	texture_color.a *= step(dissolve, random_alpha(pixel_within_texture));
	COLOR = texture_color;
}
