extends HBoxContainer

var autosave_interval: float = 5.0 : set = set_autosave_interval
var autosave_timer: Timer

func recover() -> void:
	%ToolBar.load_project_data(get_tree().current_scene.HELIUM3D_PATH + '/autosave.hlm')
	%SubViewport.refresh_taa()

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
		)
	%Load.get_popup().connect('id_pressed', func(id: int) -> void:
		if id == 1:
			_on_load_pressed()
			%FileDialog.show()
		if id == 0:
			_on_load_from_clipboard_pressed()
	)

func set_autosave_interval(value: float) -> void:
	autosave_interval = value
	if autosave_timer:
		autosave_timer.wait_time = autosave_interval
		autosave_timer.stop()
		autosave_timer.start()

func _on_autosave_timer_timeout() -> void:
	var autosave_path: String = get_tree().current_scene.HELIUM3D_PATH + '/autosave.hlm'
	if not %CrashSaveWindow.visible:
		save_project_data(autosave_path)

func save_project_data(path: String, exclude: Array[String] = [], optimize_for_clipboard: bool = false) -> void:
	if not path.ends_with('.hlm'):
		path += '.hlm'

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var data: Dictionary = get_tree().current_scene.get_app_state(optimize_for_clipboard)
		
		for item in exclude:
			if data['other'].has(item):
				data['other'].erase(item)
		
		file.store_var(data)
		file.close()

func load_project_data(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file:
		get_tree().current_scene.update_app_state(file.get_var(), true)
		%SubViewport.refresh_taa()
		file.close()

func save_image(path: String) -> void:
	if path.ends_with('.hlm'):
		path = path.trim_suffix('.hlm') + '.png'
	
	if not path.ends_with('.png') and not path.ends_with('.jpg') and not path.ends_with('.jpeg') and not path.ends_with('.webp'):
		path += '.png'
	
	var image: Image = %PostDisplay.texture.get_image()
	
	if get_tree().current_scene.using_tiling and FileAccess.file_exists(get_tree().current_scene.HELIUM3D_PATH + '/tilerender/combined.png'):
		image = Image.load_from_file(get_tree().current_scene.HELIUM3D_PATH + '/tilerender/combined.png')
	
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

func _on_load_pressed() -> void:
	%FileDialog.ok_button_text = "Open"
	%FileDialog.file_mode = %FileDialog.FILE_MODE_OPEN_FILE
	%FileDialog.title = "Load Project"
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
		load_project_data(path)

func _on_antialiasing_value_changed(option: String) -> void:
	if option == "None":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.NONE)
	elif option == "FXAA":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.FXAA)
	elif option == "SMAA":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.SMAA)
	%SubViewport.refresh_taa()
	%DummyFocusButton.grab_focus()

func _on_load_from_clipboard_pressed() -> void:
	var data: String = DisplayServer.clipboard_get()
	data = data.lstrip(' ')
	
	if not data.begins_with('Helium3D['):
		%Logs.print_console('Failed to load clip board text.')
		return
	
	data = data.trim_prefix('Helium3D[')
	if data.ends_with(']'):
		data = data.trim_suffix(']')
	
	var decoded_data: PackedByteArray = Marshalls.base64_to_raw(data)
	var decompressed_data: PackedByteArray = decoded_data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	
	var file: FileAccess = FileAccess.open(get_tree().current_scene.HELIUM3D_PATH + '/clipboard_load_buffer.hlm', FileAccess.WRITE)
	if file == null:
		%Logs.print_console('Failed to create clipboard buffer file.')
		return
	
	file.store_buffer(decompressed_data)
	file.close()
	
	load_project_data(get_tree().current_scene.HELIUM3D_PATH + '/clipboard_load_buffer.hlm')
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	%SubViewport.refresh_taa()

func _on_save_to_clipboard_pressed() -> void:
	save_project_data(get_tree().current_scene.HELIUM3D_PATH + '/clipboard_save_buffer.hlm', ['keyframes'], true)
	var file: PackedByteArray = FileAccess.get_file_as_bytes(get_tree().current_scene.HELIUM3D_PATH + '/clipboard_save_buffer.hlm')
	var compressed_data: PackedByteArray = file.compress(FileAccess.COMPRESSION_GZIP)
	var encoded_data: String = Marshalls.raw_to_base64(compressed_data)
	DisplayServer.clipboard_set('Helium3D[' + encoded_data + ']')

func _on_quality_value_changed(option: String) -> void:
	%SubViewport.set_quality(option.to_lower())
	%SubViewport.refresh_taa()
	%DummyFocusButton.grab_focus()
