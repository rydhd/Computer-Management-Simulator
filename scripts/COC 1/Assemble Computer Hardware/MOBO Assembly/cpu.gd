extends Area2D

signal installed
# NEW: A signal to tell the main scene that something went wrong
signal installation_failed(message: String) 

@export var component_type: String = "CPU" 

var is_dragging = false
var start_position = Vector2.ZERO
var is_installed = false 

func _ready() -> void:
	start_position = global_position

# 1. Start drag ONLY when the mouse is over the shape
func _input_event(_viewport, event, _shape_idx) -> void:
	if is_installed: 
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			z_index = 10

# 2. Stop drag GLOBALLY (This guarantees the item drops even if you move the mouse fast!)
func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed: # The mouse button was released!
			is_dragging = false
			z_index = 0
			_check_drop_zone()

func _process(_delta) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()

func _check_drop_zone() -> void:
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.name == "Socket_CPU": 
			if "is_open" in area and area.is_open:
				global_position = area.global_position
				is_installed = true 
				installed.emit() 
				print("CPU Locked in place!")
				return 
			else:
				# UPDATED: Emit our new signal with the exact error message!
				installation_failed.emit("Open the CPU latch first!")
				
	global_position = start_position
