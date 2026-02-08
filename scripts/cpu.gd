extends Area2D

# 1. Define what this object is
@export var component_type: String = "CPU" 

var is_dragging = false
var start_position = Vector2.ZERO

func _ready():
	start_position = global_position

# 2. This function ONLY works if the Root Node is an Area2D!
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				z_index = 10 # Bring to front
			else:
				is_dragging = false
				z_index = 0
				_check_drop_zone() 

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()

func _check_drop_zone():
	var overlapping_areas = get_overlapping_areas()
	
	# DEBUG: Print how many things we are touching
	print("I am touching ", overlapping_areas.size(), " areas.")
	
	for area in overlapping_areas:
		# DEBUG: Print the name of everything we touch
		print("I found an area named: ", area.name)
		
		# Check if we hit the correct socket
		if area.name == "Socket_CPU": 
			global_position = area.global_position
			print("SUCCESS: CPU Installed!")
			return 
	
	global_position = start_position
