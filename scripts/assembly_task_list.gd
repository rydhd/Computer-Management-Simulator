extends CanvasLayer

@onready var cpu_check: CheckBox = $PanelContainer/VBoxContainer/CpuTask
@onready var gpu_check: CheckBox = $PanelContainer/VBoxContainer/GpuTask

func _ready() -> void:
	# Start with tasks incomplete
	cpu_check.button_pressed = false
	gpu_check.button_pressed = false
	# Disable clicking them manually
	cpu_check.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gpu_check.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Called by the CPU signal
func _on_cpu_installed() -> void:
	cpu_check.button_pressed = true
	print("Task: CPU checked off!")

# Called by the GPU signal
func _on_gpu_installed() -> void:
	gpu_check.button_pressed = true
	print("Task: GPU checked off!")
