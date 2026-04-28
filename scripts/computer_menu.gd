extends Node2D

@onready var begin_button: Button = %BeginButton

# We create a variable to hold the destination, defaulting to Task 1
var next_scene_path: String = "res://scenes/hardware_assembly.tscn"

func _ready() -> void:
	# 1. ALWAYS set the button up for Task 1 by default
	if begin_button:
		begin_button.disabled = false
		begin_button.text = "Begin Task 1"
		begin_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# 2. If Task 1 is done, upgrade the button to trigger Task 2!
	if "Fix PC: System Unit Installation" in GlobalState.completed_tasks:
		_setup_task_2()

func _setup_task_2() -> void:
	if begin_button:
		# Ensure it stays enabled
		begin_button.disabled = false 
		
		# Change the text to reflect the new job
		begin_button.text = "Connect PSU" 
		
		# CRITICAL: Change the destination path to your new scene!
		# Make sure this perfectly matches your PSU scene's file path.
		next_scene_path = "res://scenes/connect_psu.tscn" 

func _on_begin_button_pressed() -> void:
	print("Button was pressed")
	var error = get_tree().change_scene_to_file("res://scenes/hardware_assembly.tscn")
	if error != OK:
		print("scene change with error code: ", error)
