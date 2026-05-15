extends Control

# This custom signal lets the main scene know the step is complete!
signal psu_installed

@export var installed_psu_texture: Texture2D
var is_connected: bool = false

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not is_visible_in_tree() or is_connected: return false
		
	# Only accept items in the "psu" category!
	if typeof(data) == TYPE_DICTIONARY and data.has("category"):
		if data["category"] == "psu":
			return true
			
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	is_connected = true
	
	if installed_psu_texture:
		var visual = TextureRect.new()
		visual.texture = installed_psu_texture
		visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		visual.set_anchors_preset(PRESET_FULL_RECT)
		add_child(visual)
		
	if data.has("source_node") and is_instance_valid(data["source_node"]):
		data["source_node"].queue_free()

	# Crucial Step: Fire the signal!
	psu_installed.emit()
