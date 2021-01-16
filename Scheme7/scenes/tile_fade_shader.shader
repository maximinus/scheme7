shader_type canvas_item;

varying vec2 world_pos;

void vertex() {
    world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
}

void fragment() {
	float intensity = 600.0 - world_pos.y;
	intensity = (intensity / 2000.0);
	COLOR = vec4(intensity / 5.0, intensity / 3.0, intensity / 1.0, 1.0);
}
