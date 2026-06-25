extends Node

var current_issue: String = ""
# This array holds the exact names of all tasks the player has finished.
var completed_tasks: Array[String] = []
# --- NEW: Store the current task sequence globally! ---
var active_tasks: Array = []
var first_job_acknowledged: bool = false

# --- SCORING & TIMER SYSTEM ---
var is_timer_running: bool = false
var current_scene_start_time: float = 0.0
# Dictionary to save the final scores for each task (e.g., {"Arrange Cables": {"time": 45.2, "score": 85}})
var task_scores: Dictionary = {}

# --- NEW: Flag to track when a player returns from a successful job ---
var customer_job_finished: bool = false

# Call this exactly when the gameplay begins
func start_scene_timer() -> void:
	# Get the engine's current uptime in seconds
	current_scene_start_time = Time.get_ticks_msec() / 1000.0 
	is_timer_running = true
	print("Timer started!")

# Call this exactly when the player completes the task
func stop_scene_timer_and_score(task_name: String, target_fast_time: float, max_slow_time: float) -> void:
	is_timer_running = false
	var end_time: float = Time.get_ticks_msec() / 1000.0
	var time_taken: float = end_time - current_scene_start_time
	
	var final_score: int = 0
	
	# SCORING LOGIC
	if time_taken <= target_fast_time:
		final_score = 100 # Perfect score if they beat the fast time!
	elif time_taken >= max_slow_time:
		final_score = 0   # Lowest score if they took too long
	else:
		# Calculate a sliding scale score between 100 and 0
		var time_range: float = max_slow_time - target_fast_time
		var time_over: float = time_taken - target_fast_time
		var penalty_percentage: float = time_over / time_range
		final_score = int(100 - (penalty_percentage * 100))
		
	# Save the results in our global dictionary
	task_scores[task_name] = {
		"time_taken": snapped(time_taken, 0.01), # Rounds to 2 decimal places
		"score": final_score
	}
	
	print("Task '", task_name, "' finished in ", snapped(time_taken, 0.01), " seconds. Score: ", final_score, "/100")
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
