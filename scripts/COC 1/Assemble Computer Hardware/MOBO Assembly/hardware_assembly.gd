extends Control

const TASK_BRIEFING_SCENE = preload("res://scenes/task_briefing_menu.tscn")

@onready var cpu = %CPU
@onready var gpu = %GPU 
@onready var ram = %Ram
@onready var task_list = %AssemblyTaskList

@onready var center_popup = %CenterPopup

# --- NEW: Reference to our separate instruction label ---
@onready var instruction_label = $InstructionLabel 
# --------------------------------------------------------

@onready var back_button = $Button 
@onready var complete_button = $CompleteButton 
@onready var button_sound = $ButtonAudio
@onready var cpu_socket = $Socket_CPU 

func _ready() -> void:
	$LatchButton.move_to_front()
	GlobalState.start_scene_timer()
	
	# --- NEW: Handle the separate Instruction Prompt ---
	if instruction_label:
		instruction_label.text = "Click and drag the parts to their correct sockets!"
		instruction_label.modulate.a = 1.0 # Ensure it is fully visible
		instruction_label.show()
		
		# Create a tween just for the instruction label so it fades out after 4 seconds
		var tween = create_tween()
		tween.tween_interval(4.0) 
		tween.tween_property(instruction_label, "modulate:a", 0.0, 1.0) 
		tween.tween_callback(func(): instruction_label.hide())
	# ---------------------------------------------------
	
	if cpu and gpu and ram and task_list and cpu_socket:
		cpu.installed.connect(task_list._on_cpu_installed)
		gpu.installed.connect(task_list._on_gpu_installed)
		ram.installed.connect(task_list._on_ram_installed)
		
		cpu.installed.connect(_check_completion)
		gpu.installed.connect(_check_completion)
		ram.installed.connect(_check_completion)
		
		cpu_socket.socket_toggled.connect(_on_socket_toggled)
		cpu.installation_failed.connect(_show_center_popup)
		
		print("Signals connected successfully!")
	else:
		push_error("One or more nodes are missing! Check Unique Names in the Editor.")
		
	if complete_button:
		complete_button.pressed.connect(_on_complete_button_pressed)

func _on_socket_toggled(is_open: bool) -> void:
	if cpu.is_installed:
		cpu.visible = is_open
		
	_check_completion()

func _check_completion() -> void:
	if cpu.is_installed and gpu.is_installed and ram.is_installed and not cpu_socket.is_open:
		print("All components installed and socket secured! Revealing Complete button.")
		complete_button.visible = true
		back_button.visible = false
	else:
		complete_button.visible = false
		back_button.visible = true

func _on_button_pressed() -> void:
	button_sound.play()
	await button_sound.finished 
	print("Player left before finishing the assembly!")
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")

func _on_complete_button_pressed() -> void:
	button_sound.play()
	await button_sound.finished 
	print("Job completed! Motherboard fully assembled.")
	
	GlobalState.stop_scene_timer_and_score("Assemble Computer Hardware", 45.0, 120.0)
	GlobalState.complete_task("Assemble Computer Hardware")
	
	var next_scene_path: String = "res://scenes/COC 1/Assemble Computer Hardware/MOBO Assembly/assemble_motherboard.tscn"
	
	var error: Error = get_tree().change_scene_to_file(next_scene_path)
	if error != OK:
		push_error("Failed to load the system unit assembly scene. Error code: ", error)	

# Center popup is now safely reserved strictly for errors/warnings!
func _show_center_popup(message: String) -> void:
	if not center_popup:
		push_warning("CenterPopup node is missing!")
		return
		
	center_popup.text = message
	center_popup.visible = true
	center_popup.modulate.a = 1.0 
	
	var tween = create_tween()
	tween.tween_interval(1.5) 
	tween.tween_property(center_popup, "modulate:a", 0.0, 0.5) 
	tween.tween_callback(func(): center_popup.visible = false)
	
