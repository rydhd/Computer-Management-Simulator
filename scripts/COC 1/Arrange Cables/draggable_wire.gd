extends TextureRect

# Set this in the Inspector for each wire (e.g., "WhiteOrange", "Blue")
@export var wire_color: String = "" 

# NEW: Track if the wire has already been used
var is_placed: bool = false 

func _get_drag_data(at_position: Vector2) -> Variant:
	# 1. Block the drag if the wire is already placed
	if is_placed:
		return null
		
	# 2. Create a visual preview of the wire being dragged
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.custom_minimum_size = custom_minimum_size
	preview_texture.modulate.a = 0.6 # Make the dragged wire slightly transparent
	
	# 3. Wrap it in a Control node to center the preview on the mouse cursor
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	preview_texture.position = -0.5 * custom_minimum_size
	
	# 4. Set the preview
	set_drag_preview(preview_control)
	
	# 5. NEW: Return a dictionary containing the color AND the node reference
	return {
		"color": wire_color,
		"original_node": self
	}
