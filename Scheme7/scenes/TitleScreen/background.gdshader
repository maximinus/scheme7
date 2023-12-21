shader_type canvas_item;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	vec3 mixed_color = mix(vec3(0.059, 0.086, 0.192), base_color.rgb, 0.2);
	COLOR = vec4(mixed_color, 1.0);
}
