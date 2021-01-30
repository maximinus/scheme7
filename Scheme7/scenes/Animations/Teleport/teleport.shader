shader_type canvas_item;
render_mode unshaded;

uniform float speed;
uniform float fade_size;
uniform vec4 line_color : hint_color;

void fragment() {
	// calculate distance from centre
	float xpos = abs(UV.x - 0.5);
	float ypos = abs(UV.y - 0.5);
	float dist = sqrt((xpos * xpos) + (ypos * ypos));
	float new_alpha = 1.0 - min(dist * fade_size, 1.0);
	
	float variance = texture(TEXTURE, UV).r / 6.0;
	if(variance > 0.5) {
		variance = 1.0 - variance;
	}
	
	vec2 pos = UV;
	if(pos.x > 0.5) {
		pos -= variance;
		pos.x -= (TIME / speed);
	} else {
		pos += variance;
		pos.x += (TIME / speed);
	}
	
	// just examine the horizontal
	pos.y = 0.0;
	vec4 noise = texture(TEXTURE, pos);
	vec4 final_color = noise * line_color;
	if(noise.r > 0.5) {
		final_color.a = new_alpha;
		final_color.b = 0.6 - new_alpha;
		COLOR = final_color;
	}
	else {
		COLOR = vec4(0, 0, 0, 0);
	}
}