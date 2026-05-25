extends TextureRect

# Set this in the Inspector for each wire (e.g., "WhiteOrange", "Blue")
@export var wire_color: String = "" 

func _get_drag_data(at_position: Vector2) -> Variant:
	# 1. Create a visual preview of the wire being dragged
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.custom_minimum_size = custom_minimum_size
	preview_texture.modulate.a = 0.6 # Make the dragged wire slightly transparent
	
	# 2. Wrap it in a Control node to center the preview on the mouse cursor
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	preview_texture.position = -0.5 * custom_minimum_size
	
	# 3. Set the preview
	set_drag_preview(preview_control)
	
	# 4. Return the data payload (the color string) to be received by the drop slot
	return wire_color
