extends CanvasLayer

@onready var time_label: Label = $MarginContainer/PanelContainer/MarginContainer/TimeLabel

func _ready() -> void:
	# Start hidden
	hide()

func _process(_delta: float) -> void:
	# 1. Safely get the current scene
	var current_scene = get_tree().current_scene
	
	# 2. Only proceed if current_scene is actually valid
	if current_scene != null:
		var current_scene_path = current_scene.scene_file_path
		
		# List of scenes where the timer should never show
		if current_scene_path == "res://scenes/shop_2d.tscn" or current_scene_path == "res://scenes/COC 1/Assemble Computer Hardware/computer_menu.tscn":
			hide()
			return 
	else:
		# If there is no scene loaded yet, definitely keep the timer hidden
		hide()
		return

	# 3. Only calculate and show the timer if a minigame is actively running
	if GlobalState.is_timer_running:
		show()
		
		# --- TIMER CALCULATION ---
		# Calculate elapsed time in seconds
		var current_time = (Time.get_ticks_msec() / 1000.0) - GlobalState.current_scene_start_time
		
		# Format into Minutes, Seconds, and Milliseconds
		var minutes: int = int(current_time) / 60
		var seconds: int = int(current_time) % 60
		var milliseconds: int = int((current_time - int(current_time)) * 100)
		
		# %02d ensures the numbers always have two digits (e.g., 05 instead of 5)
		time_label.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
		
	else:
		# Hide the overlay instantly when the timer is stopped
		hide()
