extends TextureRect

# In the Inspector, type "cable" for your wires.
@export var item_category: String = "cable"
# Specify exactly which cable this is (e.g., "24-pin", "gpu-power").
@export var specific_id: String = "" 

# Built-in Godot 4 function triggered when the user clicks and drags this node
func _get_drag_data(at_position: Vector2) -> Variant:
	# Create a visual preview that follows the mouse
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.size = Vector2(64, 64) # Adjust preview size if needed
	
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	preview_texture.position = -preview_texture.size / 2.0
	
	set_drag_preview(preview_control)
	
	# Pass the category and the specific ID to the socket
	return {
		"category": item_category,
		"id": specific_id,
		"source_node": self 
	}
