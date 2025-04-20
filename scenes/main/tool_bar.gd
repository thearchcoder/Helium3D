extends HBoxContainer

# Dedicated function to save project data
func save_project_data(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var data: Dictionary = get_tree().current_scene.fields.duplicate(true)
		var other_data: Dictionary = {}
		
		other_data["app_version"] = get_tree().current_scene.VERSION
		other_data["total_visible_formula_pages"] = %TabContainer.total_visible_formulas
		other_data["player_position"] = %Player.global_position
		other_data["head_rotation"] = %Player.get_node("Head").global_rotation_degrees
		other_data["camera_rotation"] = %Player.get_node("Head/Camera").global_rotation_degrees
		other_data["keyframes"] = %AnimationTrack.keyframes
		
		# Create a section for all gradient textures
		other_data["gradienttexture1ds"] = {}
		
		# Process all GradientTexture1D fields
		for key in (data.keys() as Array[String]):
			if data[key] is GradientTexture1D:
				var gradient_texture: GradientTexture1D = data[key] as GradientTexture1D
				if gradient_texture.gradient:
					# Store gradient data in a structured way
					other_data["gradienttexture1ds"][key] = {
						"offsets": gradient_texture.gradient.offsets,
						"colors": gradient_texture.gradient.colors
					}
				# Remove the actual texture to avoid serialization issues
				data.erase(key)
		
		# Add the processed other data
		data["other"] = other_data
		
		file.store_var(data)
		print("saving: ", data)
		file.close()
	else:
		print("Error: Could not open file for writing: ", path)

# Dedicated function to load project data
func load_project_data(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file:
		var data: Dictionary = file.get_var()
		print("loading: ", data)
		
		var other_data: Dictionary = data["other"]
		print(other_data.get('app_version'))
		
		# Process gradient texture data - convert to Gradient objects, not GradientTexture1D
		if other_data.has("gradienttexture1ds"):
			var gradient_data: Dictionary = other_data["gradienttexture1ds"]
			
			# Create proper Gradient objects for each stored gradient
			for key in (gradient_data.keys() as Array[String]):
				var gradient_info: Dictionary = gradient_data[key]
				
				# Create the gradient
				var gradient: Gradient = Gradient.new()
				gradient.offsets = gradient_info["offsets"]
				gradient.colors = gradient_info["colors"]
				
				# Add directly to main data (not as GradientTexture1D)
				data[key] = gradient
			
			# Remove the gradienttexture1ds section as we've processed it
			other_data.erase("gradienttexture1ds")
		
		# Update app state with the reconstructed data
		get_tree().current_scene.update_app_state(data)
		%SubViewport.refresh_taa()
		
		file.close()
	else:
		print("Error: Could not open file for reading: ", path)

# Save an image to the specified path
func save_image(path: String) -> void:
	var image: Image = %TextureRect.texture.get_image()
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

# Updated file dialog confirmed handler using the new functions
func _on_file_dialog_confirmed() -> void:
	if %FileDialog.title == "Save Picture":
		save_image(%FileDialog.current_path)
	elif %FileDialog.title == "Save Project":
		save_project_data(%FileDialog.current_path)
	elif %FileDialog.title == "Save Picture and Project":
		# Save project
		save_project_data(%FileDialog.current_path)
		# Save picture
		save_image(%FileDialog.current_path.replace(".hlm", "") + ".png")
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
	# Performance: (0.3, 0.77)
	# Balanced: (0.65, 0.91)
	# Quality: (1.0, 1.0)
	%SubViewport.set_quality(option.to_lower())
	%SubViewport.refresh_taa()
	%DummyFocusButton.grab_focus()
