shader_type canvas_item;

void fragment() {
	if (length(COLOR.rgb) < 0.0045) COLOR *= 0.0;
}
