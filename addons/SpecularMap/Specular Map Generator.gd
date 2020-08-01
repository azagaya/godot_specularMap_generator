tool
extends Control

var texture_rect
var viewport
var current_path = "./generated.png"
var light2d_node = null
var viewport_container_node = null
var type_of_texture = ""

func _ready():
	texture_rect = $ViewportSpecular/Specular
	viewport = $GUI/VBoxContainer/ViewportContainer/Viewport
	viewport.size = texture_rect.texture.get_size()
		
	light2d_node = $GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect/Light2D
	viewport_container_node = $GUI/ViewportContainer
	$GUI/VBoxContainer/HBoxContainer_ColorPicker/ColorPickerButton.color = light2d_node.color
	$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.material.set_shader_param("specularTexture", $ViewportSpecular.get_texture())
	$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.material.set_shader_param("screen_size",$GUI/VBoxContainer/ViewportContainer.get_rect().size)
	$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.material.set_shader_param("custom_normal",true)

func _on_SpinBoxBlur_value_changed(value):
	texture_rect.material.set_shader_param("blur",value)

func _on_Invert_toggled(button_pressed):
	texture_rect.material.set_shader_param("invert",button_pressed)

func _on_Button_pressed():
	$ViewportSpecular.size = $ViewportSpecular/Specular.texture.get_size()
	$ViewportSpecular/Specular.position = $ViewportSpecular.size/2;
	var img = $ViewportSpecular.get_texture().get_data()
	img.save_png(current_path)


func _on_TextureButton_pressed():
	# Make the file dialog half the size of the Godot editor and make it popup in the center.
	type_of_texture = "Texture"
	$FileDialog.rect_size = get_tree().root.size / 2;
	$FileDialog.popup_centered();
	$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.material.set_shader_param("custom_normal",false)


func _on_FileDialog_file_selected(path):
	var img = Image.new()
	var itex = ImageTexture.new()
	if (!img.load(path)):
		itex.create_from_image(img)
		if (type_of_texture == "Texture"):
			var aux = path.rsplit(".",true,1)
			current_path = aux[0]+"_s.png"
			# Create and Load new distance
			
			texture_rect.texture = itex
			$ViewportSpecular.size = texture_rect.texture.get_size()
			texture_rect.position = $ViewportSpecular.size/2;
			
			$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.texture = itex
		elif (type_of_texture == "Normal"):
			$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.material.set_shader_param("normal_texture",itex)
			
# Used for tracking the mouse and other input events.
# Currently this is only used to move the Light2D node.
func _input(event):
	if (event is InputEventMouseButton):
		
		var mouse_pos = get_tree().root.get_mouse_position();
		
		# Check if the mouse is within the bounds of the Viewport container
		# NOTE: this is perhaps not the most performance friendly way of checking, may need to be replaced later.
		if Rect2(viewport_container_node.rect_global_position, viewport_container_node.rect_size).has_point(get_tree().root.get_mouse_position()):
			if event.pressed == true and event.button_index == BUTTON_LEFT:
				
				# First, get the position of the mouse within the rectangle of the ViewportContainer
				var relative_mouse_pos = mouse_pos - rect_global_position
				
				# Get the position relative to the Viewport.
				# First, convert the position so it is in a 0-1 range on both axis.
				var light_pos = relative_mouse_pos / viewport_container_node.rect_size
				# Multiple by the viewport size so the position is within viewport space.
				light_pos *= $GUI/VBoxContainer/ViewportContainer/Viewport.size
				# Finally, set the position.
				light2d_node.global_position = light_pos


# Changes the Light2D node color based on input from the ColorPickerButton
func _on_ColorPickerButton_color_changed(color):
	light2d_node.color = color


func _on_SpinBoxLightScale_value_changed(value):
	light2d_node.texture_scale = value

func _on_Specular_toggled(button_pressed):
	if (button_pressed):
		$GUI/VBoxContainer/ViewportContainer/Viewport/CanvasModulate.color = Color(1.0,1.0,1.0,1.0)
	else:
		$GUI/VBoxContainer/ViewportContainer/Viewport/CanvasModulate.color = Color(0.8,0.8,0.8,1.0)
	$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.material.set_shader_param("specular_preview",button_pressed)


func _on_HSliderThresh_value_changed(value):
	texture_rect.material.set_shader_param("thresh",value)


func _on_HSliderContrast_value_changed(value):
	texture_rect.material.set_shader_param("contrast",value)


func _on_HSliderBright_value_changed(value):
	texture_rect.material.set_shader_param("bright",value)


func _on_NormalButton_pressed():
	type_of_texture = "Normal"
	$FileDialog.rect_size = get_tree().root.size / 2;
	$FileDialog.popup_centered();
	$GUI/VBoxContainer/ViewportContainer/Viewport/TextureRect.material.set_shader_param("custom_normal",true)
