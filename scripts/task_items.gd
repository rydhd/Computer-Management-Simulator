extends CanvasLayer

# Using Scene Unique Nodes!
@onready var task_1: Label = %Task1
@onready var task_2: Label = %Task2 # Make sure you set this unique name in the editor!
@onready var task_3: Label = %Task3 # Make sure you set this unique name in the editor!
@onready var task_4: Label = %Task4 # Make sure you set this unique name in the editor!

func _ready() -> void:
	# Update the UI as soon as the scene enters the active SceneTree
	_update_task_list()

func _update_task_list() -> void:
	# Ensure all 4 labels are found in the Scene Tree
	if not task_1 or not task_2 or not task_3 or not task_4:
		push_error("Task labels are missing! Check your % Unique Names in the Scene Tree.")
		return
		
	# --- DEFAULT LOCKED STATES FOR TASKS 3 & 4 ---
	task_3.visible = true
	task_3.text = "3. ??? (Locked)"
	task_3.modulate = Color(0.2, 0.2, 0.2, 0.8) # Darker grey
	
	task_4.visible = true
	task_4.text = "4. ??? (Locked)"
	task_4.modulate = Color(0.2, 0.2, 0.2, 0.8) # Darker grey
		
	# --- TASK 1 LOGIC ---
	if "Fix PC: System Unit Installation" in GlobalState.completed_tasks:
		task_1.modulate = Color(0.5, 0.5, 0.5, 0.6) 
		task_1.text = "1. Assemble motherboard [DONE]"
		
		# Reveal Task 2 as the "Active" objective
		task_2.visible = true
		task_2.text = "2. Connect PSU"
		task_2.modulate = Color(1.0, 1.0, 1.0, 1.0) 
	else:
		# Task 1 is NOT done. We keep Task 2 visible so the list is 1, 2, 3...
		# but we make it look "Locked" by greying it out.
		task_2.visible = true 
		task_2.text = "2. ??? (Locked)" # Hide the name until unlocked
		task_2.modulate = Color(0.2, 0.2, 0.2, 0.8) # Darker grey
		
	# --- TASK 2 LOGIC ---
	if "Fix PC: PSU Connected" in GlobalState.completed_tasks:
		task_2.modulate = Color(0.5, 0.5, 0.5, 0.6)
		task_2.text = "2. Connect PSU [DONE]"
		
		# In the future, this is where you would unlock Task 3!
		# task_3.text = "3. Next Objective Name"
		# task_3.modulate = Color(1.0, 1.0, 1.0, 1.0)
