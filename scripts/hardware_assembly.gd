extends Control

const TASK_BRIEFING_SCENE = preload("res://scenes/task_briefing_menu.tscn")

@onready var cpu = %CPU
@onready var gpu = %GPU 
@onready var ram = %Ram
@onready var task_list = %AssemblyTaskList

# NEW: Grab the reference to our centered popup
@onready var center_popup = %CenterPopup

@onready var back_button = $Button 
@onready var complete_button = $CompleteButton 

func _ready() -> void:
	if cpu and gpu and ram and task_list:
		# Connect to the UI checklist
		cpu.installed.connect(task_list._on_cpu_installed)
		gpu.installed.connect(task_list._on_gpu_installed)
		ram.installed.connect(task_list._on_ram_installed)
		
		# Connect to our local completion checker
		cpu.installed.connect(_check_completion)
		gpu.installed.connect(_check_completion)
		ram.installed.connect(_check_completion)
		
		# NEW: Listen for the CPU's failure signal!
		cpu.installation_failed.connect(_show_center_popup)
		
		print("Signals connected successfully!")
	else:
		push_error("One or more nodes are missing! Check Unique Names in the Editor.")
		
	if complete_button:
		complete_button.pressed.connect(_on_complete_button_pressed)
# This function runs every time a component clicks into place
func _check_completion() -> void:
	# FIX 2: Added 'and ram.is_installed' so the game waits for all 3 components
	if cpu.is_installed and gpu.is_installed and ram.is_installed:
		print("All components installed! Revealing Complete button.")
		# Show the complete button!
		complete_button.visible = true
		
		# Optional: Hide the old back button so they HAVE to click Complete
		back_button.visible = false

# The OLD back button now just acts as an "Abort / Leave Early" button
func _on_button_pressed() -> void:
	print("Player left before finishing the assembly!")
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")

# The NEW Complete button saves progress and transitions to the next assembly phase
func _on_complete_button_pressed() -> void:
	print("Job completed! Motherboard fully assembled.")
	
	# Success! Tell the GlobalState this current task is complete.
	GlobalState.complete_task("Fix PC: Motherboard Assembly")
	
	# Transition to the system unit casing scene instead of the shop
	var next_scene_path: String = "res://scenes/assemble_motherboard.tscn" # UPDATE THIS PATH
	
	var error: Error = get_tree().change_scene_to_file(next_scene_path)
	if error != OK:
		push_error("Failed to load the system unit assembly scene. Error code: ", error)
		
# NEW: The function that handles the tween animation for the center popup
func _show_center_popup(message: String) -> void:
	if not center_popup:
		push_warning("CenterPopup node is missing!")
		return
		
	# 1. Update the text and show the label
	center_popup.text = message
	center_popup.visible = true
	center_popup.modulate.a = 1.0 # Ensure it is fully visible
	
	# 2. Animate the fade out using a Tween
	var tween = create_tween()
	tween.tween_interval(1.5) # Wait 1.5 seconds
	tween.tween_property(center_popup, "modulate:a", 0.0, 0.5) # Fade to invisible over 0.5 seconds
	tween.tween_callback(func(): center_popup.visible = false) # Hide node completely
