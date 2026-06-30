extends Control

# --- NEW: Custom signal to announce a successful connection ---
signal cable_plugged_in

@export var required_cable_id: String = ""
@export var plugged_in_texture: Texture2D

var is_connected: bool = false
var is_hovered: bool = false # Track if the mouse is hovering

# --- NEW: Connect hover signals when the node is ready ---
func _ready() -> void:
	mouse_entered.connect(_on_mouse_hover_entered)
	mouse_exited.connect(_on_mouse_hover_exited)

func _on_mouse_hover_entered() -> void:
	# Only show the highlight if a cable hasn't been plugged in yet
	if not is_connected:
		is_hovered = true
		queue_redraw() # Tells Godot to run the _draw() function

func _on_mouse_hover_exited() -> void:
	is_hovered = false
	queue_redraw()

# --- NEW: Draw the semi-transparent green box ---
func _draw() -> void:
	if is_hovered:
		# Draws a box matching the node's size with 30% opacity green
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 1.0, 0.0, 0.3))

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not is_visible_in_tree() or is_connected: 
		return false
		
	if typeof(data) == TYPE_DICTIONARY and data.has("category"):
		if data["category"] == "cable" and data["id"] == required_cable_id:
			return true 
			
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	is_connected = true
	is_hovered = false # Turn off the highlight when dropped
	queue_redraw()     # Clear the drawn rectangle immediately
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
