extends Area2D

signal installed

@export var component_type: String = "GPU" 

var is_dragging = false
var start_position = Vector2.ZERO
var is_installed = false # New variable to track state

func _ready():
	start_position = global_position

func _input_event(_viewport, event, _shape_idx):
	# If already installed, stop right here and ignore the click!
	if is_installed: 
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				z_index = 10
			else:
				is_dragging = false
				z_index = 0
				_check_drop_zone() 

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position()

func _check_drop_zone():
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
