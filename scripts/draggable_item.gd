extends TextureRect

# In the Inspector, type "cable" for your wires.
@export var item_category: String = "cable"
# Specify exactly which cable this is (e.g., "24-pin", "gpu-power").
@export var specific_id: String = "" 

# --- Connect hover signals when the node is ready ---
func _ready() -> void:
	mouse_entered.connect(_on_mouse_hover_entered)
	mouse_exited.connect(_on_mouse_hover_exited)

# --- Brighten the texture on hover ---
func _on_mouse_hover_entered() -> void:
	modulate = Color(1.5, 1.5, 1.5, 1.0) 

# --- Reset the texture when the mouse leaves ---
func _on_mouse_hover_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)

# Built-in Godot 4 function triggered when the user clicks and drags this node
func _get_drag_data(at_position: Vector2) -> Variant:
	# Create a visual preview that follows the mouse
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	
	# --- FIX: Make the dragged cable bigger and keep its shape ---
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Change these numbers to make the drag image as big as you want!
	# (It was previously stuck at a tiny 64x64)
	preview_texture.size = Vector2(200, 200) 
	# -------------------------------------------------------------
	
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	
	# Center the big image directly on the mouse cursor
	preview_texture.position = -preview_texture.size / 2.0
	
	set_drag_preview(preview_control)
	
	# Pass the category and the specific ID to the socket
	return {
		"category": item_category,
		"id": specific_id,
		"source_node": self 
	}
