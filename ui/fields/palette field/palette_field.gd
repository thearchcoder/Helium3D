extends HBoxContainer

const BLOCK_SCENE = preload('res://ui/fields/palette field color block/palette_field_color_block.tscn')

signal value_changed(to: Dictionary)
var value: Dictionary = {'special_field': true, 'type': 'palette', 'is_blurry': false, 'offsets': PackedFloat32Array([0.0]), 'colors': PackedColorArray([Color('white')])}:
	set(val):
		value = val
		value_changed.emit(value)
		var offsets: PackedFloat32Array = value['offsets']
		var colors: PackedColorArray = value['colors']
		
		changed_gradient()
		
		for block in %Blocks.get_children():
			%Blocks.remove_child(block)
		
		for i in len(offsets):
			var color := colors[i]
			var offset := offsets[i]
			var block := BLOCK_SCENE.instantiate()
			block.offset = offset
			block.color = color
			%Blocks.add_child(block)
			block.set_block_offset(block.offset)
			block.position.y = size.y - 23
		
		changed_gradient()
		
		for block in %Blocks.get_children():
			%Blocks.remove_child(block)
		
		for i in len(offsets):
			var color := colors[i]
			var offset := offsets[i]
			var block := BLOCK_SCENE.instantiate()
			block.offset = offset
			block.color = color
			%Blocks.add_child(block)
			block.set_block_offset(block.offset)
			block.position.y = size.y - 23
		
		changed_gradient()
		Global.action_occurred()

func _ready() -> void:
	Global.value_nodes.append(self)
	# Call setter to reposition color blocks
	# For some reason, I have to do it twice to properly position them
	value = value
	value = value
	value_changed.emit(value)

func i_am_a_palette_field() -> void: pass

func changed_gradient() -> void:
	var offsets := PackedFloat32Array()
	var colors := PackedColorArray()
	var is_blurry: bool = value['is_blurry']
	
	for block in %Blocks.get_children():
		offsets.append(block.offset)
		colors.append(block.color)
	
	var gradient: Gradient = Gradient.new()
	gradient.offsets = offsets
	gradient.colors = colors
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT if not is_blurry else Gradient.GRADIENT_INTERPOLATE_CUBIC
	
	var gradient_texture: GradientTexture1D = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	%TextureRect.texture = gradient_texture
	value_changed.emit({'special_field': true, 'type': 'palette', 'is_blurry': value['is_blurry'], 'offsets': offsets, 'colors': colors})

func _on_button_button_down() -> void:
	var block := BLOCK_SCENE.instantiate()
	%Blocks.add_child(block)
	block.offset = 0.5
	
	var first_pos: Vector2 = %Blocks.get_child(0).position
	block.position = Vector2(0, size.y - 23)
	
	block.is_dragging = true
	block.prevent_opening_colorpicker = true
	block.drag_start_x = get_global_mouse_position().x - 1
	block.original_position_x = get_global_mouse_position().x - block.global_position.x - 6
	block.offset = block.position.x / $MarginContainer.size.x

func _on_blur_button_pressed() -> void:
	value['is_blurry'] = !value['is_blurry']
	changed_gradient()
