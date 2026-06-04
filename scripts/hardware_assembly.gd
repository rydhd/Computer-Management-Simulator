extends Control

const TASK_BRIEFING_SCENE = preload("res://scenes/task_briefing_menu.tscn")

@onready var cpu = %CPU
@onready var gpu = %GPU 
@onready var ram = %Ram
@onready var task_list = %AssemblyTaskList

@onready var center_popup = %CenterPopup
@onready var back_button = $Button 
@onready var complete_button = $CompleteButton 

# 1. Grab the reference to the CPU Socket Node
@onready var cpu_socket = $Socket_CPU 

func _ready() -> void:
	if cpu and gpu and ram and task_list and cpu_socket:
		cpu.installed.connect(task_list._on_cpu_installed)
		gpu.installed.connect(task_list._on_gpu_installed)
		ram.installed.connect(task_list._on_ram_installed)
		
		cpu.installed.connect(_check_completion)
		gpu.installed.connect(_check_completion)
		ram.installed.connect(_check_completion)
		
		# 2. Connect the new socket toggle signal
		cpu_socket.socket_toggled.connect(_on_socket_toggled)
		
		cpu.installation_failed.connect(_show_center_popup)
		
		print("Signals connected successfully!")
	else:
		push_error("One or more nodes are missing! Check Unique Names in the Editor.")
		
	if complete_button:
		complete_button.pressed.connect(_on_complete_button_pressed)

# 3. Create a function to handle the signal from the socket
# 3. Create a function to handle the signal from the socket
func _on_socket_toggled(is_open: bool) -> void:
	# Check if the CPU is already placed in the socket
	if cpu.is_installed:
		# If the socket is open, show the CPU. If closed, hide it.
		cpu.visible = is_open
		
	# Continue to check if the job is complete
	_check_completion()

# 4. Modify the completion logic
func _check_completion() -> void:
	# Enforce that all components are installed AND the CPU socket is closed
	if cpu.is_installed and gpu.is_installed and ram.is_installed and not cpu_socket.is_open:
		print("All components installed and socket secured! Revealing Complete button.")
		complete_button.visible = true
		back_button.visible = false
	else:
		# If they open the socket after completing, hide the Complete button again
		complete_button.visible = false
		back_button.visible = true

func _on_button_pressed() -> void:
	print("Player left before finishing the assembly!")
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")

func _on_complete_button_pressed() -> void:
	print("Job completed! Motherboard fully assembled.")
	GlobalState.complete_task("Fix PC: Motherboard Assembly")
	
	var next_scene_path: String = "res://scenes/COC 1/Assemble Computer Hardware/MOBO Assembly/assemble_motherboard.tscn"
	
	var error: Error = get_tree().change_scene_to_file(next_scene_path)
	if error != OK:
		push_error("Failed to load the system unit assembly scene. Error code: ", error)
		
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
	
