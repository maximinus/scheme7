shader_type canvas_item;
render_mode unshaded;

uniform float speed;
uniform float fade_size;
uniform float gap;
uniform vec4 line_color : hint_color;

void fragment() {
	if((UV.x <= gap) || (UV.x > (1.0 - gap))) {
		if((UV.y < gap) || (UV.y > (1.0 - gap))) {
			COLOR = vec4(0,0,0,0);
			return;	
		}
	}
	
	// calculate distance from centre
	float xpos = abs(UV.x - 0.5);
	float ypos = abs(UV.y - 0.5);
	float dist = sqrt((xpos * xpos) + (ypos * ypos));
	float new_alpha = 1.0 - min(dist * fade_size, 1.0);
	
	//float variance = texture(TEXTURE, UV).r / 2.0;
	vec2 pos = UV;
	pos.y = new_alpha;
	float variance = texture(TEXTURE, pos).r;
	if(variance >= 0.5) {
		variance = 1.0 - variance;
	}
	
	pos = UV;
	if(pos.x > 0.5) {
		pos.x -= variance;
		pos.x -= (TIME / speed);
	} else {
		pos.x += variance;
		pos.x += (TIME / speed);
	}
	if(pos.y > 0.5) {
		pos.y -= variance;
		pos.y -= (TIME / speed);
	} else {
		pos.y += variance;
		pos.y += (TIME / speed);
	}
	
	// just examine the horizontal
	pos.y = 0.0;
	vec4 noise = texture(TEXTURE, pos);
	vec4 final_color = noise * line_color;
	if(noise.r > 0.5) {
		final_color.a = new_alpha;
		final_color.b = 0.2 - new_alpha;
		final_color.g = new_alpha / 8.0;
		COLOR = final_color;
	}
	else {
		COLOR = vec4(0, 0, 0, 0);
	}
}