shader_type canvas_item;

uniform float line_thickness = 0.01;
uniform vec4 line_color : source_color = vec4(1, 1, 1, 1);
uniform bool selecting = false;

uniform sampler2D curve_texture : repeat_disable, filter_linear;


void fragment() {
	float curve = texture(curve_texture, UV).r;
	float line = curve - (1.0 - UV.y);
	line = abs(line);
	line = step(line, line_thickness * (1.0 + fwidth(curve) * 100.0)); // fwidth for uniform line thickness but i'm not sure if it's good enough
	
	vec4 l_color = line_color;
	if (selecting) {
		l_color = vec4(1.0, 1.0, 1.0, 1.0);
	}
	
	COLOR = mix(vec4(0.0, 0.0, 0.0, 0.0), l_color, line);
}