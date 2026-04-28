extends CanvasLayer

# Using Scene Unique Nodes!
@onready var task_1: Label = %Task1
@onready var task_2: Label = %Task2 # Make sure you set this unique name in the editor!

func _ready() -> void:
	# Update the UI as soon as the scene enters the active SceneTree
	_update_task_list()

func _update_task_list() -> void:
	# Ensure the Labels actually exist to prevent null instance crashes
	if not task_1 or not task_2:
		push_error("Task labels are missing from the scene tree!")
		return
		
	# --- TASK 1 LOGIC ---
	if "Fix PC: System Unit Installation" in GlobalState.completed_tasks:
		# 1. Mark Task 1 as Done
		task_1.modulate = Color(0.5, 0.5, 0.5, 0.6) 
		task_1.text = "1. Assemble motherboard [DONE]"
		
		# 2. Reveal Task 2 so the player knows what to do next!
		task_2.visible = true
		task_2.text = "2. Connect PSU"
		task_2.modulate = Color(1.0, 1.0, 1.0, 1.0) # Ensure it is fully visible
	else:
		# If Task 1 IS NOT done, keep Task 2 hidden
		task_2.visible = false
		
	# --- TASK 2 LOGIC ---
	# IMPORTANT: Change "Fix PC: PSU Connected" to whatever string you actually 
	# pass to GlobalState.complete_task() at the end of the arrange_cables scene!
	if "Fix PC: PSU Connected" in GlobalState.completed_tasks:
		# Mark Task 2 as Done
		task_2.modulate = Color(0.5, 0.5, 0.5, 0.6)
		task_2.text = "2. Connect PSU [DONE]"
