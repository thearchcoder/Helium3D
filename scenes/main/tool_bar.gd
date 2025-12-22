extends HBoxContainer

var autosave_interval: float = 5.0 : set = set_autosave_interval
var autosave_timer: Timer
var field_filter: String = 'project'
var has_saved_before: bool = false
var saved_path: String = ""

var global_settings: Dictionary = {
	"difficulty": "simple",
	"texture_filter": "Linear",
	"low_scaling": 0.4,
	"bottom_bar_height": 200.0,
	"tab_container_ratio": 1.0
}
@onready var HELIUM3D_PATH: String = (OS.get_environment("USERPROFILE") if OS.get_name() == "Windows" else OS.get_environment("HOME")) + Global.path("/.hlm")
@onready var global_settings_path: String = HELIUM3D_PATH + Global.path('/global_settings.hlm')

func recover() -> void:
	%ToolBar.load_project_data(get_tree().current_scene.HELIUM3D_PATH + Global.path('/autosave.hlm'), 'project', true)
	%SubViewport.refresh()

func _ready() -> void:
	autosave_timer = Timer.new()
	autosave_timer.wait_time = autosave_interval
	autosave_timer.timeout.connect(_on_autosave_timer_timeout)
	autosave_timer.autostart = true
	add_child(autosave_timer)
	
	%Save.get_popup().connect('id_pressed', func(id: int) -> void:
		if id == 0:
			_on_save_all_pressed()
			%FileDialog.show()
		if id == 1:
			_on_save_pressed()
			%FileDialog.show()
		if id == 2:
			_on_save_picture_pressed()
			%FileDialog.show()
		if id == 3:
			_on_save_to_clipboard_pressed()
		if id == 4 and has_saved_before:
			save_project_data(saved_path)
			%ProgramStateLabel.text = "Saving file"
			await get_tree().create_timer(0.2).timeout
			%ProgramStateLabel.text = "Rendered"
		)
	%Load.get_popup().connect('id_pressed', func(id: int) -> void:
		if id == 0:
			_on_load_from_clipboard_pressed()
		if id == 1:
			_on_load_pressed('project')
			%FileDialog.show()
		if id == 2:
			_on_load_pressed('lighting')
			%FileDialog.show()
		if id == 3:
			_on_load_pressed('fractal')
			%FileDialog.show()
	)
	%General.get_popup().connect('id_pressed', func(id: int) -> void:
		if id == 0:
			get_tree().current_scene._on_about_button_pressed()
		if id == 1:
			get_tree().current_scene._on_author_button_pressed()
		if id == 2:
			get_tree().current_scene.undo()
		if id == 3:
			get_tree().current_scene.redo()
		if id == 8:
			recover()
		if id == 9:
			show_reset_default_popup()
		if id == 4:
			# TODO: Make a website. (examples page)
			pass
		if id == 5:
			# TODO: Make a website.
			pass
		)
	
	await get_tree().process_frame
	load_global_settings()

func show_reset_default_popup() -> void:
	%ResetDefaultWindow.visible = true

func set_autosave_interval(value: float) -> void:
	autosave_interval = value
	if autosave_timer:
		autosave_timer.wait_time = autosave_interval
		autosave_timer.stop()
		autosave_timer.start()

func _on_autosave_timer_timeout() -> void:
	var autosave_path: String = get_tree().current_scene.HELIUM3D_PATH + Global.path('/autosave.hlm')
	if not %CrashSaveWindow.visible and get_tree().current_scene.made_changes:
		save_project_data(autosave_path, true)

func save_project_data(path: String, is_buffer: bool = false, exclude: Array[String] = [], optimize_for_clipboard: bool = false) -> void:
	if not path.ends_with('.hlm'):
		path += '.hlm'

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var data: Dictionary = get_tree().current_scene.get_app_state(optimize_for_clipboard)
		#print(data)
		
		for item in exclude:
			if data['other'].has(item):
				data['other'].erase(item)
		
		if file.store_var(data) and not is_buffer:
			has_saved_before = true
			saved_path = path
			%Save.get_popup().set_item_disabled(4, false)
			DisplayServer.window_set_title("Helium3D (" + path.get_file().split('.')[0] + ')', get_window().get_window_id())
		
		file.close()

func load_project_data(path: String, load_field_filter: String, is_buffer: bool = false) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file:
		var fields: Dictionary = file.get_var()
		
		if not fields:
			Global.error('Failed to get clipboard data. (buffer load error)')
		
		if load_field_filter != "" and load_field_filter != "project":
			var filtered_fields: Dictionary = {}
			
			if load_field_filter == "lighting":
				var lighting_prefixes := [
					"light1_", "light2_",
					"bg_type", "bg_color", "bg_image", "transparent_bg",
					"hard_shadows", "shadow_steps", "shadow_epsilon", "shadow_raystep_multiplier",
					"specular_intensity", "specular_sharpness",
					"reflection_intensity", "reflection_bounces",
					"ambient_occlusion_distance", "ambient_occlusion_radius", "ambient_occlusion_steps", "ambient_occlusion_light_affect",
					"ambient_light", "ambient_light_from_background", "ambient_light_color",
					"normal_map", "normal_map_enabled", "normal_map_projection", "normal_map_scale", "normal_map_triplanar_sharpness", "normal_map_height", "normal_epsilon", "connect_normal_to_epsilon",
					"fresnel_color", "fresnel_intensity", "fresnel_falloff"
				]
				
				for key in (fields.keys() as Array[String]):
					for prefix in (lighting_prefixes as Array[String]):
						if key == prefix or key.begins_with(prefix):
							filtered_fields[key] = fields[key]
							break
			elif load_field_filter == "fractal":
				var fractal_exact := ["sphere_inversion", "inversion_sphere", "translation", "rotation", "kalaidoscope", "kalaidoscope_mode"]
				var formula_regex := RegEx.new()
				formula_regex.compile("^f[a-z]+_")
				
				for key in (fields.keys() as Array[String]):
					if key in fractal_exact or formula_regex.search(key):
						filtered_fields[key] = fields[key]
			
			fields = filtered_fields
		
		if not is_buffer:
			has_saved_before = true
			saved_path = path
			%Save.get_popup().set_item_disabled(4, false)
			DisplayServer.window_set_title("Helium3D (" + path.get_file().split('.')[0] + ')', get_window().get_window_id())

		get_tree().current_scene.update_app_state(fields, true)
		%SubViewport.refresh()
		file.close()

func save_image(path: String) -> void:
	if path.ends_with('.hlm'):
		path = path.trim_suffix('.hlm') + '.png'
	
	if not path.ends_with('.png') and not path.ends_with('.jpg') and not path.ends_with('.jpeg') and not path.ends_with('.webp'):
		path += '.png'
	
	var image: Image = %TextureRect.texture.get_image()
	
	if %Fractal.material_override.get_shader_parameter('tiled') and get_tree().current_scene.last_tiled_render_image:
		image = get_tree().current_scene.last_tiled_render_image
	
	if path.ends_with(".png") and %Fractal.material_override.get_shader_parameter('transparent_bg'):
		image.convert(Image.FORMAT_RGBA8)
		for x in range(image.get_width()):
			for y in range(image.get_height()):
				var pixel: Color = image.get_pixel(x, y)
				if pixel.r == 0.0 and pixel.g == 0.0 and pixel.b == 0.0:
					image.set_pixel(x, y, Color(0, 0, 0, 0))
	
	if path.ends_with(".jpg") or path.ends_with(".jpeg"):
		image.save_jpg(path)
	elif path.ends_with(".webp"):
		image.save_webp(path)
	else:
		image.save_png(path)

func _on_save_picture_pressed() -> void:
	if %FileDialog.current_path.ends_with(".hlm"):
		%FileDialog.current_path = %FileDialog.current_path.trim_suffix('.hlm') + '.png'
	
	%FileDialog.file_mode = %FileDialog.FILE_MODE_SAVE_FILE
	%FileDialog.title = "Save Picture"
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.png, *.jpg, *.jpeg, *.webp", "Images")

func _on_load_pressed(load_field_filter: String) -> void:
	field_filter = load_field_filter
	%FileDialog.ok_button_text = "Open"
	%FileDialog.file_mode = %FileDialog.FILE_MODE_OPEN_FILE
	%FileDialog.title = "Load " + load_field_filter.capitalize()
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.hlm", "Helium3D Files")

func _on_save_pressed() -> void:
	if %FileDialog.current_path.ends_with(".png"):
		%FileDialog.current_path = %FileDialog.current_path.trim_suffix('.png') + '.hlm'
	
	%FileDialog.file_mode = %FileDialog.FILE_MODE_SAVE_FILE
	%FileDialog.ok_button_text = "Save"
	%FileDialog.title = "Save Project"
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.hlm", "Helium3D Files")

func _on_save_all_pressed() -> void:
	if %FileDialog.current_path.ends_with(".png"):
		%FileDialog.current_path = %FileDialog.current_path.trim_suffix('.png') + '.hlm'
	
	%FileDialog.file_mode = %FileDialog.FILE_MODE_SAVE_FILE
	%FileDialog.ok_button_text = "Save"
	%FileDialog.title = "Save Picture and Project"
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.hlm", "Helium3D Files")

func _on_file_dialog_confirmed(path: String) -> void:
	if %FileDialog.title == "Save Picture":
		save_image(path)
	elif %FileDialog.title == "Save Project":
		save_project_data(path)
	elif %FileDialog.title == "Save Picture and Project":
		save_project_data(path)
		save_image(path)
	elif %FileDialog.title == "Load Project":
		load_project_data(path, 'project')
	elif %FileDialog.title == "Load Fractal":
		load_project_data(path, 'fractal')
	elif %FileDialog.title == "Load Lighting":
		load_project_data(path, 'lighting')

func _on_antialiasing_value_changed(option: String) -> void:
	if option == "None":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.NONE)
	elif option == "FXAA":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.FXAA)
	elif option == "SMAA":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.SMAA)
	%SubViewport.refresh()
	%DummyFocusButton.grab_focus()

func _on_load_from_clipboard_pressed() -> void:
	var data: String = DisplayServer.clipboard_get()
	data = data.replace(' ', '')
	
	if not data.begins_with('Helium3D['):
		Global.error('Invalid data format. A proper Helium3D clipboard file should look something like "Helium3D[a bunch of cryptic text]".')
		return
	
	data = data.trim_prefix('Helium3D[')
	if data.ends_with(']'):
		data = data.trim_suffix(']')
	
	var decoded_data: PackedByteArray = Marshalls.base64_to_raw(data)
	if decoded_data.is_empty():
		Global.error('Clipboard data is corrupted (invalid base64).')
		return
	
	var decompressed_data: PackedByteArray = decoded_data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	
	var file: FileAccess = FileAccess.open(get_tree().current_scene.HELIUM3D_PATH + Global.path('/clipboard_load_buffer.hlm'), FileAccess.WRITE)
	if file == null:
		Global.error('Failed to load clipboard. (buffer save error)')
		return
	
	file.store_buffer(decompressed_data)
	file.close()
	
	load_project_data(get_tree().current_scene.HELIUM3D_PATH + Global.path('/clipboard_load_buffer.hlm'), 'project', true)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	%SubViewport.refresh()

func _on_save_to_clipboard_pressed() -> void:
	save_project_data(get_tree().current_scene.HELIUM3D_PATH + Global.path('/clipboard_save_buffer.hlm'), true, ['keyframes'], true)
	var file: PackedByteArray = FileAccess.get_file_as_bytes(get_tree().current_scene.HELIUM3D_PATH + Global.path('/clipboard_save_buffer.hlm'))
	var compressed_data: PackedByteArray = file.compress(FileAccess.COMPRESSION_GZIP)
	var encoded_data: String = Marshalls.raw_to_base64(compressed_data)
	DisplayServer.clipboard_set('Helium3D[' + encoded_data + ']')

func _on_quality_value_changed(option: String) -> void:
	%SubViewport.set_quality(option.to_lower())
	%SubViewport.refresh()
	%DummyFocusButton.grab_focus()

func _on_reset_cancel_button_pressed() -> void:
	%ResetDefaultWindow.visible = false
	%DummyFocusButton.grab_focus()

func _on_reset_confirm_button_pressed() -> void:
	DisplayServer.window_set_title("Helium3D")
	field_filter = "project"
	has_saved_before = false
	saved_path = ""
	get_tree().current_scene.reset_to_default()

	%ResetDefaultWindow.visible = false
	%DummyFocusButton.grab_focus()

func load_global_settings() -> void:
	if not FileAccess.file_exists(global_settings_path):
		save_global_settings()
		return

	var file: FileAccess = FileAccess.open(global_settings_path, FileAccess.READ)
	if file:
		var loaded_settings: Variant = file.get_var()
		file.close()

		if loaded_settings is Dictionary:
			for key: String in (loaded_settings.keys() as Array[String]):
				global_settings[key] = loaded_settings[key]

	apply_global_settings()

func save_global_settings() -> void:
	var file: FileAccess = FileAccess.open(global_settings_path, FileAccess.WRITE)
	if file:
		file.store_var(global_settings)
		file.close()

func set_global_setting(key: String, value: Variant) -> void:
	if Engine.get_frames_drawn() <= 1:
		return

	global_settings[key] = value
	save_global_settings()

func get_global_setting(key: String, default_value: Variant = null) -> Variant:
	return global_settings.get(key, default_value)

func apply_global_settings() -> void:
	var main: Node3D = get_tree().current_scene

	if global_settings.has("difficulty"):
		main.difficulty = global_settings["difficulty"]
		%DifficultyButton.text = 'Advanced Mode' if main.difficulty == 'advanced' else 'Simple Mode'
		main.reload_difficulty()

	if global_settings.has("texture_filter"):
		get_tree().current_scene.update_app_state({"texture_filter": global_settings["texture_filter"]})

	if global_settings.has("low_scaling"):
		get_tree().current_scene.update_app_state({"low_scaling": global_settings["low_scaling"]})

	if global_settings.has("bottom_bar_height"):
		var bottom_bar: TabContainer = main.get_node("UI/BottomBar")
		var current_panel: Control = bottom_bar.get_current_tab_control()
		#if current_panel:
			#current_panel.custom_minimum_size.y = global_settings["bottom_bar_height"]

	if global_settings.has("tab_container_ratio"):
		var tab_container: TabContainer = main.get_node("UI/HBoxContainer/TabContainer")
		#tab_container.size_flags_stretch_ratio = global_settings["tab_container_ratio"]
