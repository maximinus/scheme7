shader_type canvas_item;

uniform float range : hint_range(0.0, 0.1, 0.005)= 0.05;
uniform float offsetIntensity : hint_range(-0.1, 0.1, 0.001) = 0.03;
uniform float colorOffsetIntensity : hint_range(0.0, 5.0, 0.001) = 1.3;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float UVY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, UVY) * offset;
    x -= smoothstep(pos, edge1, UVY) * offset;
    return x;
}
const float saturation = 0.2;
void fragment()
{
    vec2 uv = SCREEN_UV;
    for (float i = 0.0; i < 1.0; i += 0.3741)
    {
        float d = mod(TIME * i, 0.7);
        float o = sin(1.0 - tan(TIME * 0.24 * i));
    	o *= offsetIntensity;
        uv.x += verticalBar(d, UV.y, o);
    }
	
	if(uv.x == SCREEN_UV.x) {
		COLOR = texture(SCREEN_TEXTURE, uv);
	} else {
		vec2 offsetR = vec2(0.009 * sin(TIME), 0.0) * colorOffsetIntensity;
		vec2 offsetG = vec2(0.0073 * (cos(TIME * 0.97)), 0.0) * colorOffsetIntensity;
    
		float r = texture(SCREEN_TEXTURE, uv + offsetR).r;
		float g = texture(SCREEN_TEXTURE, uv + offsetG).g;
		float b = texture(SCREEN_TEXTURE, uv).b;
		vec4 tex = vec4(r, g, b, 1.0);
		COLOR = tex;
	}
}
