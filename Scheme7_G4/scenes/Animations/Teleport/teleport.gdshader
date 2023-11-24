shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : source_color;
uniform float radius;
uniform float width;
const float PI = 3.1415926535897;

void fragment() {
    float xscale = 1.0;
    float yscale = 1.0;
    vec2 centre = vec2(0.5, 0.5);
    float angle = atan((UV.y - centre.y) / (UV.x - centre.x));
    float l = distance(centre, UV);
    
	float r = radius * 0.26 + cos(angle * 20.0 + TIME * 3.0 + l * 100.0) * 0.01;
	float w = clamp(radius, 0.0, 1.0) * width + cos(angle * 14.0 + TIME * 10.0 + l * 100.0) * 0.03;
	
	w = max(0.0, w);
	r = r + cos(TIME * 3.0) * 0.02;
	r = max(0.0, r);
	
	float w2 = w / 2.0;
	float v = cos(clamp(l - r, -w2, w2) / w2 * PI / 2.0);
	float light = clamp(v, 0.01, 1.0);

	float alpha = color.a;
	vec4 final_color = color * light;
	final_color += textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	final_color.a = alpha;
	COLOR = final_color;
}	
