extends Control

@onready var begin_button: Button = %BeginButton
@onready var system_unit_sprite: TextureRect = $SystemUnit
@onready var button_sound: AudioStreamPlayer = $ButtonAudio
@onready var time_warning_label: Label = $TimeWarningLabel 

const MOBO_INSTALLED_TEX = preload("res://assets/COC 1/Assemble Computer Hardware/Lets Assemble Computer Hardware/System unit.png")

# Start by assuming they are on Task 1
var next_scene_path: String = "res://scenes/COC 1/Assemble Computer Hardware/MOBO Assembly/hardware_assembly.tscn"

func _ready() -> void:
	if begin_button and not begin_button.pressed.is_connected(_on_begin_button_pressed):
		begin_button.pressed.connect(_on_begin_button_pressed)
		
	# Setup Default Button state (Task 1)
	if begin_button:
		begin_button.disabled = false
		begin_button.text = "Assemble MOBO"
		begin_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Default time warning for Task 1 matching your target_fast_time
	if time_warning_label:
		time_warning_label.text = "Perfect Score: Under 45.0s!"
		time_warning_label.modulate = Color(1, 0.84, 0) # Gold color
	
	print("--- MENU LOADED ---")
	print("Current GlobalState array: ", GlobalState.completed_tasks)
	
	if "Fix PC: System Unit Installation" in GlobalState.completed_tasks:
		if system_unit_sprite:
			system_unit_sprite.texture = MOBO_INSTALLED_TEX
			system_unit_sprite.scale = Vector2(1.3, 1.8)
		_setup_task_2()
		
	if "Insert Cables" in GlobalState.completed_tasks:
		_setup_task_4()
		
	if "Test PC" in GlobalState.completed_tasks:
		_setup_all_done()


# --- HELPER FUNCTIONS FOR SCENE PATHS ---

func _setup_task_2() -> void:
	begin_button.text = "Connect PSU"
	next_scene_path = "res://scenes/COC 1/Assemble Computer Hardware/Insert Cables/insert_cables.tscn" 
	# Update text for Task 2 target_fast_time
	if time_warning_label:
		time_warning_label.text = "Perfect Score: Under 30.0s!"
	
func _setup_task_4() -> void:
	begin_button.text = "Test PC"
	next_scene_path = "res://scenes/COC 1/Assemble Computer Hardware/test_phase.tscn"
	# Update text for Task 3 target_fast_time
	if time_warning_label:
		time_warning_label.text = "Perfect Score: Under 20.0s!"

func _setup_all_done() -> void:
	begin_button.text = "Return to Shop"
	next_scene_path = "res://scenes/shop_2d.tscn"
	# Hide the label since they are finished with the tasks
	if time_warning_label:
		time_warning_label.hide()


# --- CLICKING THE BUTTON ---
func _on_begin_button_pressed() -> void:
	button_sound.play()
	await button_sound.finished 
	
	if next_scene_path != "res://scenes/shop_2d.tscn":
		# Calling this function sets current_scene_start_time and is_timer_running to true
		GlobalState.start_scene_timer()
		
	var err = get_tree().change_scene_to_file(next_scene_path)
	if err != OK:
		push_error("Failed to load scene. Check this file path: " + next_scene_path)
