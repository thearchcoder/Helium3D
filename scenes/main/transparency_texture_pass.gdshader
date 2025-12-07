shader_type canvas_item;

uniform bool transparent_bg;

void fragment() {
	if (transparent_bg && length(COLOR.rgb) < 0.0045) COLOR *= 0.0;
}
