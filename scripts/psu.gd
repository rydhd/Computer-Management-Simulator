extends TextureRect

# In the Inspector, type "psu" for the PSU node, and "cable" for the wires!
@export var item_category: String = ""
# If it's a cable, specify which one (e.g., "24-pin"). Leave blank for the PSU.
@export var specific_id: String = "" 

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.size = Vector2(128, 128) # Adjust preview size if needed
	
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	preview_texture.position = -preview_texture.size / 2.0
	
	set_drag_preview(preview_control)
	
	# Pass both the category (PSU vs Cable) and the specific ID to the drop zone
	return {
		"category": item_category,
		"id": specific_id,
		"source_node": self 
	}
