shader_type canvas_item;

uniform sampler2D logo_black;
uniform sampler2D logo_white;
uniform sampler2D logo_shadow;

void fragment() {
	vec4 base_color = texture(logo_black, UV);
	base_color = vec4(1.0 - base_color.rgb, base_color.a);
	vec4 highlight = texture(logo_white, UV);
	
	// green: sin of x position; blue: offset sin
	// red: sin of y position
	float time_scale = TIME * 0.2;
	vec2 off = UV + time_scale;
	float green = (sin(PI * 2.0 * off.x) + 1.0) / 2.0;
	float blue_angle = mod(off.x + 0.5, 1.0);
	float blue = (sin(PI * 2.0 * blue_angle) + 1.0) / 2.0;
	float red = (cos(PI * 2.0 * off.y) + 1.0) / 2.0;
	
	vec3 highlight_color = vec3(red, green, blue);
	if(highlight.a > 0.0) {
		vec3 mixed_color = mix(highlight_color, texture(TEXTURE, UV).rgb, 0.6);
		mixed_color = mix(base_color.rgb, mixed_color, highlight.a);
		COLOR = vec4(mixed_color, 1.0);
	} else {
		vec4 background = texture(logo_shadow, UV);
		if(background.a > 0.0) {
			COLOR = mix(background, base_color, background.a * 1.5);
		} else {
			COLOR = vec4(0.0, 0.0, 0.0, 0.0);
		}
	}
}
