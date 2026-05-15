extends TextureRect

# Set this in the Inspector for each cable! (e.g., "24-pin", "SATA")
@export var cable_type: String = ""

# Built-in Godot 4 function triggered when the user clicks and drags this node
func _get_drag_data(at_position: Vector2) -> Variant:
	# 1. Create a visual preview that follows the mouse
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.size = Vector2(64, 64) # Adjust to your preferred preview size
	
	# 2. Center the preview on the mouse pointer
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	preview_texture.position = -preview_texture.size / 2.0
	
	# Tell Godot to use this visual as the drag preview
	set_drag_preview(preview_control)
	
	# 3. Pass data to the drop zone. 
	# We include 'source_node: self' so the socket can delete this icon from the tray later!
	return {
		"type": "cable",
		"cable_id": cable_type,
		"source_node": self 
	}
