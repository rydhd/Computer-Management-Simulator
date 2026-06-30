extends TextureRect

# Set this from 0 to 7 in the Inspector for each of the 8 slots
@export var slot_index: int = 0 

# Signal to notify the main arrange_cables.gd script when a wire is placed
signal wire_dropped(index: int, color: String)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# UPDATED: Accept the drop if the data is a Dictionary containing "color".
	# The 'and texture == null' condition is removed so players can overwrite mistakes.
	return typeof(data) == TYPE_DICTIONARY and data.has("color")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	# Extract the color from our dictionary payload
	var dropped_color: String = data["color"]
	
	# Construct the exact file path using your specific project directory
	var file_path: String = "res://assets/COC 1/Arrange Cables/wires/" + dropped_color + ".png"
	
	# Check if the file actually exists to prevent game crashes
	if ResourceLoader.exists(file_path):
		var new_texture: Texture2D = load(file_path)
		# Overwrite the current texture with the newly dropped wire
		texture = new_texture
	else:
		printerr("Texture not found at path: ", file_path)
		
	# Disable the newly dropped original wire so it cannot be dragged again
	data["original_node"].is_placed = true
	
	# Dim the original wire in the inventory so the player knows it is used
	data["original_node"].modulate.a = 0.3 
	
	# Notify the main game logic
	emit_signal("wire_dropped", slot_index, dropped_color)
