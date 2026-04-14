extends Node2D

@onready var cpu = %CPU
@onready var gpu = %GPU # Changed to all caps to match typical naming
@onready var task_list = %AssemblyTaskList

func _ready() -> void:
	# Check if nodes exist before trying to connect signals
	if cpu and gpu and task_list:
		cpu.installed.connect(task_list._on_cpu_installed)
		gpu.installed.connect(task_list._on_gpu_installed)
		print("Signals connected successfully!")
	else:
		push_error("One or more nodes are missing! Check Unique Names in the Editor.")


func _on_button_pressed() -> void:
	var error = get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
