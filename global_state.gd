extends Node

var current_issue: String = ""
# This array holds the exact names of all tasks the player has finished.
var completed_tasks: Array[String] = []

func complete_task(task_name: String) -> void:
	if task_name not in completed_tasks:
		completed_tasks.append(task_name)
		print("GlobalState: Task completed -> ", task_name)

func reset_game_state() -> void:
	completed_tasks.clear()
	print("Global state has been reset for a new game.")

func set_game_resolution(width: int, height: int, is_fullscreen: bool=false)-> void:
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		var new_size = Vector2i(width, height)
		DisplayServer.window_set_size(new_size)
		
		var screen_index = DisplayServer.window_get_current_screen()
		var screen_size = DisplayServer.screen_get_size(screen_index)
		var window_position = (screen_size / 2) - (new_size / 2)
		DisplayServer.window_set_position(window_position)
		
	print("Resolution updated to: ", width, "x", height)
