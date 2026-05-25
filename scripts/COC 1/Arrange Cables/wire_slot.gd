extends TextureRect

# Set this from 0 to 7 in the Inspector for each of the 8 slots
@export var slot_index: int = 0 

# Signal to notify the main arrange_cables.gd script when a wire is placed
signal wire_dropped(index: int, color: String)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Only accept the drop if the data is a String and the slot is currently empty
	# Assuming texture is null when empty. If using a placeholder texture, check a boolean instead.
	return typeof(data) == TYPE_STRING and texture == null

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var dropped_color: String = data
	
	# Construct the exact file path using your specific project directory
	var file_path: String = "res://assets/COC 1/Arrange Cables/wires/" + dropped_color + ".png"
	
	# Check if the file actually exists to prevent game crashes
	if ResourceLoader.exists(file_path):
		var new_texture: Texture2D = load(file_path)
		texture = new_texture
	else:
		printerr("Texture not found at path: ", file_path)
	
	# Notify the main game logic
	emit_signal("wire_dropped", slot_index, dropped_color)
