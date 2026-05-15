extends Area2D

signal installed

@export var component_type: String = "RAM" 

var is_dragging = false
var start_position = Vector2.ZERO
var is_installed = false # State tracker

func _ready():
	start_position = global_position

# 1. LOCAL INPUT: Only triggers when clicking ON the RAM's CollisionShape2D
func _input_event(_viewport, event, _shape_idx):
	if is_installed: 
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			z_index = 10

# 2. GLOBAL INPUT: Triggers anywhere on the screen, ensuring we never miss the drop!
func _input(event):
	if not is_dragging:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed: # The player released the mouse button
			is_dragging = false
			z_index = 0
			_check_drop_zone()
			# Tell the engine we handled this input so it doesn't click other things behind it
			get_viewport().set_input_as_handled()

func _process(_delta):
	if is_dragging:
		# Godot 4 tip: You can use lerp() here for a smoother drag, 
		# but direct assignment is great for a snappy, 1:1 feel.
		global_position = get_global_mouse_position()

func _check_drop_zone():
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		# CRITICAL: This string is case-sensitive! Ensure the node is named exactly "Socket_Ram" in the scene tree.
		if area.name == "Socket_RAM": 
			global_position = area.global_position
			is_installed = true 
			is_dragging = false 
			installed.emit() 
			print("RAM Locked in place!")
			return 
	
	# If no socket was found, snap it back to the table
	global_position = start_position
