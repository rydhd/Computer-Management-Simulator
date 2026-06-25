extends CanvasLayer

@onready var time_label: Label = $MarginContainer/PanelContainer/MarginContainer/TimeLabel

func _ready() -> void:
	# Start hidden
	hide()

func _process(_delta: float) -> void:
	# Only calculate and show the timer if a minigame is actively running
	if GlobalState.is_timer_running:
		show()
		
		# Calculate elapsed time
		var current_time = (Time.get_ticks_msec() / 1000.0) - GlobalState.current_scene_start_time
		
		# Format into Minutes, Seconds, and Milliseconds
		var minutes: int = int(current_time) / 60
		var seconds: int = int(current_time) % 60
		var milliseconds: int = int((current_time - int(current_time)) * 100)
		
		# %02d ensures the numbers always have two digits (e.g., 05 instead of 5)
		time_label.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	else:
		# Hide the overlay instantly when the task is finished
		hide()
