extends CanvasLayer

# Using Scene Unique Nodes!
@onready var task_1: Label = %Task1
@onready var task_2: Label = %Task2 
@onready var task_3: Label = %Task4 

func _ready() -> void:
	# Update the UI as soon as the scene enters the active SceneTree
	_update_task_list()

func _update_task_list() -> void:
	if not task_1 or not task_2 or not task_3 :
		push_error("Task labels are missing! Check your % Unique Names in the Scene Tree.")
		return
		
	# --- DEFAULT STATES (Task 1 Active, others Locked) ---
	task_1.text = "1. Assemble motherboard"
	task_1.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	task_2.visible = true
	task_2.text = "2. Connect PSU (Locked)"
	task_2.modulate = Color(0.2, 0.2, 0.2, 0.8) # Darker grey
	
	
	task_3.visible = true
	task_3.text = "3. Test PC (Locked)"
	task_3.modulate = Color(0.2, 0.2, 0.2, 0.8) 
		
	# --- CASCADING COMPLETION LOGIC ---
	
	# If Task 1 is done...
	if "Fix PC: System Unit Installation" in GlobalState.completed_tasks:
		task_1.modulate = Color(0.5, 0.5, 0.5, 0.6) 
		task_1.text = "1. Assemble motherboard [DONE]"
		
		# Reveal Task 2
		task_2.text = "2. Connect PSU"
		task_2.modulate = Color(1.0, 1.0, 1.0, 1.0) 

	# If Task 2 is done...
	# FIX: Look for "Insert Cables" instead of "Connect PSU"
	if "Insert Cables" in GlobalState.completed_tasks:
		task_2.modulate = Color(0.5, 0.5, 0.5, 0.6) 
		task_2.text = "2. Connect PSU [DONE]"
		
		# Reveal Task 4
		task_3.text = "3. Test PC"
		task_3.modulate = Color(1.0, 1.0, 1.0, 1.0) 
		
		
	# If Task 4 is done...
	if "Test PC" in GlobalState.completed_tasks:
		task_3.modulate = Color(0.5, 0.5, 0.5, 0.6) 
		task_3.text = "3. Test PC [DONE]"
