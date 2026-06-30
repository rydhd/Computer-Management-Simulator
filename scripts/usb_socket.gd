extends Control

signal cable_plugged_in

@export var required_cable_id: String = ""
# --- NEW: Allows you to nudge the USB X/Y pixels in the Inspector ---
@export var drop_offset: Vector2 = Vector2.ZERO 

var is_connected: bool = false
var is_hovered: bool = false 

func _ready() -> void:
	mouse_entered.connect(_on_mouse_hover_entered)
	mouse_exited.connect(_on_mouse_hover_exited)

func _on_mouse_hover_entered() -> void:
	if not is_connected:
		is_hovered = true
		queue_redraw()

func _on_mouse_hover_exited() -> void:
	is_hovered = false
	queue_redraw()

# Draws a green highlight over the socket zone
func _draw() -> void:
	if is_hovered:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 1.0, 0.0, 0.3))

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not is_visible_in_tree() or is_connected: 
		return false
		
	if typeof(data) == TYPE_DICTIONARY and data.has("id"):
		if data["id"] == required_cable_id:
			return true 
			
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	is_connected = true
	is_hovered = false 
	queue_redraw()     
	
	if data.has("source_node") and is_instance_valid(data["source_node"]):
		var usb = data["source_node"]
		
		# --- FIX 1: Align the centers of the nodes perfectly ---
		var center_pos = global_position + (size / 2.0) - ((usb.size * usb.scale) / 2.0)
		usb.global_position = center_pos + drop_offset
		
		# --- FIX 2: Completely turn off the mouse so it can never be dragged again ---
		usb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	cable_plugged_in.emit()
