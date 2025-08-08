extends SubViewport

@onready var black_image: Image = %ProgressionWhiteNoise.material.get_shader_parameter('previous_pixels')
var reset_frame: bool = false
var time: float = 0.0

func reset() -> void:
	reset_frame = true
	time = 0.0

func _ready() -> void:
	size = %SubViewport.size

func _process(delta: float) -> void:
	size = %SubViewport.size
	time += delta
	var pixels_to_render: ImageTexture = ImageTexture.create_from_image(get_texture().get_image())
	%ProgressionWhiteNoise.material.set_shader_parameter('base_selection_ratio', get_tree().current_scene.fields['progression_strength'] / 100.0)
	%ProgressionWhiteNoise.material.set_shader_parameter('time', time)
	%Fractal.material_override.set_shader_parameter('pixels_to_render', pixels_to_render)
	%PostDisplay.material.set_shader_parameter('pixels_to_render', pixels_to_render)
	
	if not reset_frame:
		%ProgressionWhiteNoise.material.set_shader_parameter('previous_pixels', pixels_to_render)
	else:
		%ProgressionWhiteNoise.material.set_shader_parameter('previous_pixels', black_image)
		reset_frame = false
