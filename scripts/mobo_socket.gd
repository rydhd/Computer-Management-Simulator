extends TextureRect

# --- NEW: Custom signal to announce a successful connection ---
signal cable_plugged_in

@export var required_cable_id: String = ""
@export var plugged_in_texture: Texture2D

var is_connected: bool = false

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not is_visible_in_tree() or is_connected: 
		return false
		
	if typeof(data) == TYPE_DICTIONARY and data.has("category"):
		if data["category"] == "cable" and data["id"] == required_cable_id:
			return true 
			
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	is_connected = true
	print("Successfully connected the " + data["id"] + " cable!")
	
	if plugged_in_texture:
		var visual = TextureRect.new()
		visual.texture = plugged_in_texture
		visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		visual.set_anchors_preset(PRESET_FULL_RECT) 
		add_child(visual)
		
	if data.has("source_node") and is_instance_valid(data["source_node"]):
		data["source_node"].queue_free()

	# --- NEW: Fire the signal! ---
	cable_plugged_in.emit()
