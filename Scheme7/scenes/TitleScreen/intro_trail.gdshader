shader_type canvas_item;

uniform float size;
uniform float max_length;
uniform vec4 trail_color : source_color;

void fragment() {
	// we need some calculation
	// the circle leaves behind a trail of paint, the color would be
	// based on the distance away from the circle; which is based on the
	// length of the line
	// we only have a y value for the UV with no sense of size
	// so the real distance is the size * UV
	float real_distance = size * UV.x;
	// the drop off in color should be relative to this
	// and also linear, so it will go to 0 at some distance
	// so at 200 pixels away alpha is zero
	float value = (1.0 - UV.x) * size;
	if(value > max_length) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		float alpha = (value / max_length);
		COLOR = mix(trail_color, vec4(0.0, 0.0, 0.0, 0.0), alpha);
	}
}
