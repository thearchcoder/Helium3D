extends MarginContainer

@onready var animation_track: Control = get_tree().current_scene.get_node('%AnimationTrack')
var time_accumulator: float = 0.0
var playing: bool = false
var at_frame: int = 0:
	set(value):
		at_frame = clamp(value, 0, len(animation_track.exported_video) - 1)
		
		if len(animation_track.exported_video) > at_frame and at_frame >= 0:
			var image := Image.new()
			image.load_webp_from_buffer(animation_track.exported_video[at_frame])
			%Frame.texture = ImageTexture.create_from_image(image)
		
		update_slider()

func _process(delta: float) -> void:
	if playing:
		if at_frame >= len(animation_track.exported_video) - 1:
			stop()
			return
		
		var speeds := [0.1, 0.2, 0.5, 1.0, 1.2, 1.5, 2.0, 3.0]
		var speed: float = speeds[%PlaySpeed.selected]
		time_accumulator += delta * speed * 60.0
		
		var frames_to_advance := int(time_accumulator)
		if frames_to_advance > 0:
			at_frame = min(at_frame + frames_to_advance, len(animation_track.exported_video) - 1)
			time_accumulator -= frames_to_advance

func update_slider() -> void:
	$VBoxContainer/HBoxContainer/HSlider.max_value = max(len(animation_track.exported_video) - 1, 1)
	$VBoxContainer/HBoxContainer/HSlider.set_value_no_signal(at_frame)

func toggle() -> void:
	playing = not playing
	if playing and at_frame == len(animation_track.exported_video) - 1:
		at_frame = 0
		time_accumulator = 0.0
	print_exported_video_memory()

func print_exported_video_memory() -> void:
	var total_bytes: int = 0
	for frame_data in (animation_track.exported_video as Array[PackedByteArray]):
		if typeof(frame_data) == TYPE_PACKED_BYTE_ARRAY:
			total_bytes += frame_data.size()

func play() -> void:
	playing = true
	at_frame = 0
	time_accumulator = 0.0

func stop() -> void:
	playing = false
	time_accumulator = 0.0

func update_texture(image: Image) -> void:
	%Frame.texture = ImageTexture.create_from_image(image)

func left() -> void:
	if playing:
		stop()
	
	at_frame = 0

func right() -> void:
	if playing:
		stop()
	
	at_frame = len(animation_track.exported_video) - 1

func _on_h_slider_value_changed(value: float) -> void:
	at_frame = int(value)
	stop()
