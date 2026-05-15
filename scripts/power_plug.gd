extends TextureRect

# What cable belongs in this socket? Match the spelling from DraggableCable exactly!
@export var required_cable: String = ""

# Optional: A texture to show the wire actually plugged in
@export var plugged_in_texture: Texture2D

var is_connected: bool = false

# Built-in Godot function: Can the dragged data be dropped here?
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if is_connected: 
		return false # Already plugged in
		
	# Check if the dragged data is a dictionary, is a cable, and matches our required socket
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "cable":
		if data["cable_id"] == required_cable:
			return true # The correct cable is hovering!
			
	return false

# Built-in Godot function: Execute the drop
func _drop_data(at_position: Vector2, data: Variant) -> void:
	is_connected = true
	print("Successfully connected the " + data["cable_id"] + " cable!")
	
	# 1. Visual feedback: Change to plugged-in graphic
	if plugged_in_texture:
		var visual = TextureRect.new()
		visual.texture = plugged_in_texture
		visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		visual.set_anchors_preset(PRESET_FULL_RECT) # Fill the socket bounds
		add_child(visual)
		
	# 2. Remove the cable from the Cable Tray so the player can't use it twice!
	if data.has("source_node") and is_instance_valid(data["source_node"]):
		data["source_node"].queue_free()
