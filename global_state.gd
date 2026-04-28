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
