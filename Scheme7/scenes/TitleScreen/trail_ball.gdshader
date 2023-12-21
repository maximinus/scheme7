shader_type canvas_item;

uniform vec4 ball_color: source_color;

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	if(UV.y < 0.5) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		COLOR = mix(vec4(0.0, 0.0, 0.0, 0.0), ball_color, texture(TEXTURE, UV).a);
	}
}
