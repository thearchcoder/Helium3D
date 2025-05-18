extends HBoxContainer

func save_project_data(path: String) -> void:
	if not path.ends_with('.hlm'):
		path += '.hlm'

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var data: Dictionary = get_tree().current_scene.get_app_state()
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
		path = path.replace('.hlm', '.png')
	
	if not path.ends_with('.png') and not path.ends_with('.jpg') and not path.ends_with('.jpeg') and not path.ends_with('.webp'):
		path += '.png'
	
	var image: Image = %TextureRect.texture.get_image()
	
	if get_tree().current_scene.using_tiling and FileAccess.file_exists(get_tree().current_scene.HELIUM3D_PATH + '/tilerender/combined.png'):
		image = Image.load_from_file(get_tree().current_scene.HELIUM3D_PATH + '/tilerender/combined.png')
	
	if path.ends_with(".jpg") or path.ends_with(".jpeg"):
		image.save_jpg(path)
	elif path.ends_with(".webp"):
		image.save_webp(path)
	else:
		image.save_png(path)

# Original button handlers
func _on_save_picture_pressed() -> void:
	if %FileDialog.current_path.ends_with(".hlm"):
		%FileDialog.current_path = %FileDialog.current_path.replace(".hlm", ".png")
	
	%FileDialog.ok_button_text = "Save Picture"
	%FileDialog.title = "Save Picture"
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.png, *.jpg, *.jpeg, *.webp", "Images")
	%FileDialog.show()

func _on_load_pressed() -> void:
	%FileDialog.ok_button_text = "Load"
	%FileDialog.title = "Load Project"
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.hlm", "Helium3D Files")
	%FileDialog.show()

func _on_save_pressed() -> void:
	if %FileDialog.current_path.ends_with(".png"):
		%FileDialog.current_path = %FileDialog.current_path.replace(".png", ".hlm")
	
	%FileDialog.ok_button_text = "Save"
	%FileDialog.title = "Save Project"
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.hlm", "Helium3D Files")
	%FileDialog.show()

func _on_save_all_pressed() -> void:
	if %FileDialog.current_path.ends_with(".png"):
		%FileDialog.current_path = %FileDialog.current_path.replace(".png", ".hlm")
	
	%FileDialog.ok_button_text = "Save"
	%FileDialog.title = "Save Picture and Project"
	%FileDialog.clear_filters()
	%FileDialog.add_filter("*.hlm", "Helium3D Files")
	%FileDialog.add_filter("*.png, *.jpg, *.jpeg, *.webp", "Images")
	%FileDialog.show()

func _on_file_dialog_confirmed() -> void:
	if %FileDialog.title == "Save Picture":
		save_image(%FileDialog.current_path)
	elif %FileDialog.title == "Save Project":
		save_project_data(%FileDialog.current_path)
	elif %FileDialog.title == "Save Picture and Project":
		# Save project
		save_project_data(%FileDialog.current_path)
		# Save picture
		save_image(%FileDialog.current_path)
	elif %FileDialog.title == "Load Project":
		load_project_data(%FileDialog.current_path)

func _on_antialiasing_value_changed(option: String) -> void:
	if option == "None":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.NONE)
	elif option == "TAA":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.TAA)
	elif option == "FXAA":
		%SubViewport.set_antialiasing(%SubViewport.AntiAliasing.FXAA)
	%SubViewport.refresh_taa()
	%DummyFocusButton.grab_focus()

func _on_quality_value_changed(option: String) -> void:
	%SubViewport.set_quality(option.to_lower())
	%SubViewport.refresh_taa()
	%DummyFocusButton.grab_focus()
