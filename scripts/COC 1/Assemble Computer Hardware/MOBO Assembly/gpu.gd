extends Area2D

signal installed

@export var component_type: String = "GPU" 

var is_dragging = false
var start_position = Vector2.ZERO
var is_installed = false # New variable to track state

func _ready():
	start_position = global_position

# 1. Start drag ONLY when the mouse is over the shape
func _input_event(_viewport, event, _shape_idx) -> void:
	if is_installed: 
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			z_index = 10

# 2. Stop drag GLOBALLY
func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed: # The mouse button was released!
			is_dragging = false
			z_index = 0
			_check_drop_zone()

func _process(_delta) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()
		
		# --- NEW: Highlight green when dragged over the socket ---
		var is_over_socket = false
		for area in get_overlapping_areas():
			if area.name == "Socket_GPU":
				is_over_socket = true
				break
				
		if is_over_socket:
			modulate = Color(0.2, 1.0, 0.2, 1.0) # Light Green
		else:
			modulate = Color(1.0, 1.0, 1.0, 1.0) # Normal color
		# ---------------------------------------------------------

func _check_drop_zone():
	# --- NEW: Reset the color when the player releases the mouse ---
	modulate = Color(1.0, 1.0, 1.0, 1.0) 
	
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.name == "Socket_GPU": 
			global_position = area.global_position
			is_installed = true # Lock the component
			is_dragging = false # Force stop dragging
			installed.emit() 
			print("GPU Locked in place!")
			return 
	
	global_position = start_position
