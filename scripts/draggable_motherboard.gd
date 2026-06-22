extends Area2D

signal installed
signal motherboard_placed

@export var component_type: String = "Motherboard" 

var is_dragging: bool = false
var start_position: Vector2 = Vector2.ZERO
var is_installed: bool = false 
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	start_position = global_position

# 1. LOCAL EVENT: Only fires when the mouse clicks ON this specific component
func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start dragging
			is_dragging = true
			# Calculate offset so the item doesn't teleport to the mouse center immediately
			drag_offset = global_position - get_global_mouse_position()
		else:
			# Stop dragging on mouse release
			is_dragging = false
			_check_drop_zone()

# 2. GLOBAL EVENT: Fires for all inputs across the entire screen
func _input(event: InputEvent) -> void:
	# If we are currently dragging this object, and the player releases the Left Mouse Button...
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed: # The button was released!
			is_dragging = false
			z_index = 0
			_check_drop_zone()

func _process(delta: float) -> void:
	if is_dragging:
		# Follow the mouse while maintaining the initial click offset
		global_position = get_global_mouse_position() + drag_offset

func _check_drop_zone() -> void:
	# Get all Area2Ds currently overlapping with the motherboard
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		# Check if the area we dropped it on is the tray
		if area.name == "Motherboard_Tray":
			
			# Snap the motherboard perfectly to the center of the tray
			global_position = area.global_position
			
			# Emit the signal to trigger the screw phase in the main script
			installed.emit()
			
			# Disable further dragging
			set_process(false)
			input_pickable = false
			return # Exit the function since we successfully placed it
	
	# Snap back to the start if dropped in the wrong spot
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", start_position, 0.2).set_trans(Tween.TRANS_SINE)
	
	# Emit the signal to notify the main scene
	motherboard_placed.emit()
	# Optional: Disable dragging so the player can't move it while screwing it in
	set_process_input(false)
