extends Control

const SCORE_POPUP_SCENE = preload("res://scenes/score_popup.tscn")
const NPC_SCENE = preload("res://scenes/NpcCustomer.tscn")
const ISSUE_POPUP_SCENE = preload("res://scenes/issue_popup_ui.tscn")
const MANUAL_POPUP_SCENE = preload("res://scenes/manual_popup.tscn") 

# --- HOVER ASSETS ---
const MANUAL_NORMAL = preload("res://assets/2D Assets/2D Materials/Background Manual.png")
const MANUAL_HOVER = preload("res://assets/2D Assets/2D Materials/manual hover.png") 

const BELL_NORMAL = preload("res://assets/2D Assets/2D Materials/Background Bell.png")
const BELL_HOVER = preload("res://assets/2D Assets/2D Materials/bell hover.png") # CHECK THIS PATH

const TASKBOARD_NORMAL = preload("res://assets/2D Assets/2D Materials/Background Taskboard.png")
const TASKBOARD_HOVER = preload("res://assets/2D Assets/2D Materials/taskboard hover.png") # CHECK THIS PATH
# --------------------

# --- TEXTURE RECTS (BACKGROUNDS) ---
@onready var background_manual: TextureRect = $BackgroundManual
@onready var background_bell: TextureRect = $BackgroundBell
@onready var background_taskboard: TextureRect = $BackgroundTaskboard
# -----------------------------------

@onready var manual_sound = $BackgroundManual/ManualSound
@onready var bell_sound = $BackgroundBell/BellSound
@onready var npc_spawn_position: Control = $NpcSpawnPoint
@onready var dialogue_system = $DialogueSystem
@onready var taskboard_overlay = $TaskboardOverlay

# --- BUTTONS ---
@onready var manual_button: Button = $BackgroundManual/ManualButton 
@onready var bell_button: Button = $BackgroundBell/BellButton
@onready var taskboard_button: Button = $BackgroundTaskboard/TaskboardButton

# Tracks the current instances
var current_npc: Area2D = null 
var current_popup: Node = null
var manual_popup_instance: Node = null 
var is_processing_bell: bool = false

func _ready() -> void:
	# Connect the hover signals for the Manual Button
	if manual_button:
		manual_button.mouse_entered.connect(_on_manual_hover_entered)
		manual_button.mouse_exited.connect(_on_manual_hover_exited)
		
	# Connect the hover signals for the Bell Button
	if bell_button:
		bell_button.mouse_entered.connect(_on_bell_hover_entered)
		bell_button.mouse_exited.connect(_on_bell_hover_exited)
		
	# Connect the hover signals for the Taskboard Button
	if taskboard_button:
		taskboard_button.mouse_entered.connect(_on_taskboard_hover_entered)
		taskboard_button.mouse_exited.connect(_on_taskboard_hover_exited)
		
	# --- BULLETPROOF TUTORIAL OVERRIDE ---
	if GlobalState.completed_tasks.size() > 0:
		TutorialManager.current_step = TutorialManager.TutorialStep.COMPLETED

	# Connect the manual button pressed signal
	if manual_button and not manual_button.pressed.is_connected(_on_manual_button_pressed):
		manual_button.pressed.connect(_on_manual_button_pressed)

	# ==========================================================
	# --- DYNAMIC STATE MACHINE FOR RETURNING TO THE SHOP ---
	# ==========================================================
	
	# Safely determine if ALL main tasks are actually done
	var all_main_tasks_done: bool = false
	
	if GlobalState.active_tasks.size() > 0:
		all_main_tasks_done = true
		for task in GlobalState.active_tasks:
			# If even one main task is missing from the completed list, they aren't done!
			if not GlobalState.completed_tasks.has(task["name"]):
				all_main_tasks_done = false
				break

	if all_main_tasks_done:
		print("All tasks for customer finished! Playing completion dialogue.")
		
		# 1. SPAWN THE NPC BACK IN
		current_npc = NPC_SCENE.instantiate()
		current_npc.scale = Vector2(0.3, 0.3)
		
		# --- UPDATE: Check which customer is returning based on the task ---
		if GlobalState.active_tasks[0]["name"] == "Set-up Computer Networks":
			current_npc.my_name = "Miyamura"
			current_npc.my_outro = "Thanks! The network is up and running smoothly."
			GlobalState.set_meta("miyamura_finished", true)
		else:
			current_npc.my_name = "Chase"
			GlobalState.set_meta("chase_finished", true)
		# ----------------------------------------------------------------
		
		$NpcLayer.add_child(current_npc)
		current_npc.global_position = npc_spawn_position.global_position
		current_npc.modulate = Color.WHITE # Ensure they are fully visible immediately
		
		# Wait half a second for the scene to settle
		await get_tree().create_timer(0.5).timeout
		
		# 2. Play the NPC's specific "Thank You" dialogue
		dialogue_system.show_dialogue(current_npc.my_name + ": " + current_npc.my_outro)
		await dialogue_system.dialogue_finished
		
		# --- NEW: SHOW THE SCORE SCREEN ---
		var score_screen = SCORE_POPUP_SCENE.instantiate()
		add_child(score_screen)
		score_screen.display_scores(GlobalState.active_tasks)
		
		# Wait here until the player clicks the "Collect Payment" button
		await score_screen.closed
		# ----------------------------------
		
		# 3. Fade the NPC out as they leave the shop
		var tween = create_tween()
		tween.tween_property(current_npc, "modulate:a", 0.0, 1.0)
		await tween.finished
		current_npc.queue_free()
		
		# 4. Clear the board for the next customer
		GlobalState.completed_tasks.clear()
		GlobalState.active_tasks.clear()
		GlobalState.customer_job_finished = false 
		
		# 5. Have Chip the Robot prompt the next loop
		EventBus.trigger_robot_dialogue.emit("Excellent work! Click the bell again to invite a new customer.")
		await EventBus.continue_tutorial_dialogue
		EventBus.fade_out_robot.emit()
		
		# 6. Point to the bell for the next customer
		EventBus.show_bell_arrow.emit()
		
	# 2. Did they just finish OS Install (Task 2)?
	elif "Installing Operating System" in GlobalState.completed_tasks and not GlobalState.has_meta("os_install_acknowledged"):
		get_tree().create_timer(1.0).timeout.connect(_on_os_install_complete)
		
	# 3. Did they just finish Hardware Assembly (Task 1)?
	elif "Assemble Computer Hardware" in GlobalState.completed_tasks and not GlobalState.first_job_acknowledged:
		get_tree().create_timer(1.0).timeout.connect(_on_first_job_complete)
		
	# 4. Is this the very beginning of the game?
	elif TutorialManager.current_step == TutorialManager.TutorialStep.START:
		get_tree().create_timer(1.0).timeout.connect(TutorialManager.start_tutorial)
		

# ==========================================
# --- HOVER LOGIC FUNCTIONS ---
# ==========================================

# --- Manual Hover ---
func _on_manual_hover_entered() -> void:
	if background_manual:
		background_manual.texture = MANUAL_HOVER

func _on_manual_hover_exited() -> void:
	if background_manual:
		background_manual.texture = MANUAL_NORMAL

# --- Bell Hover ---
func _on_bell_hover_entered() -> void:
	if background_bell:
		background_bell.texture = BELL_HOVER

func _on_bell_hover_exited() -> void:
	if background_bell:
		background_bell.texture = BELL_NORMAL

# --- Taskboard Hover ---
func _on_taskboard_hover_entered() -> void:
	if background_taskboard:
		background_taskboard.texture = TASKBOARD_HOVER

func _on_taskboard_hover_exited() -> void:
	if background_taskboard:
		background_taskboard.texture = TASKBOARD_NORMAL


# ==========================================
# --- REST OF GAMEPLAY LOGIC ---
# ==========================================

func _on_os_install_complete() -> void:
	EventBus.trigger_robot_dialogue.emit("Great job! You successfully installed the Operating System.")
	await EventBus.continue_tutorial_dialogue
	
	EventBus.trigger_robot_dialogue.emit("Open the Taskboard to check off your task and move on to arranging the cables!")
	await EventBus.continue_tutorial_dialogue
	
	EventBus.fade_out_robot.emit()
	GlobalState.set_meta("os_install_acknowledged", true)

func _on_first_job_complete() -> void:
	EventBus.trigger_robot_dialogue.emit("Great work getting that PC assembled!")
	await EventBus.continue_tutorial_dialogue
	
	EventBus.trigger_robot_dialogue.emit("Open the Taskboard to check off your task and grab your next job!")
	await EventBus.continue_tutorial_dialogue
	
	EventBus.fade_out_robot.emit()
	GlobalState.first_job_acknowledged = true

func _on_bell_button_pressed() -> void:
	if is_processing_bell:
		return
		
	# NEW: Prevent spawning if the player is already working on an active job
	if GlobalState.active_tasks.size() > 0:
		print("Job already in progress. Finish the current task first.")
		return
		
	if is_instance_valid(current_npc):
		print("An NPC is already here. Help them first!")
		return
		
	is_processing_bell = true
	print("Bell pressed! Attempting to spawn NPC.")
	
	$BackgroundBell/BellSound.play()
	EventBus.hide_bell_arrow.emit()
	
	current_npc = NPC_SCENE.instantiate()
	current_npc.scale = Vector2(0.3, 0.3) 
	
	if not GlobalState.has_meta("chase_finished"):
		current_npc.my_name = "Chase"
		current_npc.my_id = "task_001_chase"
	else:
		current_npc.my_name = "Miyamura"
		current_npc.my_intro = "Hi! My office computers can't talk to each other. Can you set up our network?"
		current_npc.my_outro = "Thanks! The network is up and running smoothly."
		current_npc.my_issues = ["Set-up Computer Networks"]
		current_npc.my_id = "task_002_network"
		current_npc.get_node("Sprite2D").texture = load("res://assets/2D Assets/2D Materials/npc_2_miyamura.png")
	
	$NpcLayer.add_child(current_npc)
	current_npc.global_position = npc_spawn_position.global_position
	
	current_npc.fade_in_and_signal()
	await current_npc.fade_in_complete
	
	EventBus.npc_arrived.emit()
	
	# FIX: Await the dialogue function to prevent early resetting of the bell state
	await start_npc_dialogue(current_npc.my_intro, current_npc.my_name, current_npc.my_issues, current_npc.my_id)
	
	is_processing_bell = false
func start_npc_dialogue(intro_text: String, customer_name: String, issues: Array, issue_id: String) -> void:
	if is_instance_valid(dialogue_system):
		var dialogue_lines: Array[String] = [
			intro_text,
			"Can you fix these for me?"
		]
		
		dialogue_system.start_dialogue(dialogue_lines)
		await dialogue_system.dialogue_finished
		
		if not is_inside_tree():
			return 
		
		if is_instance_valid(current_popup):
			current_popup.queue_free()
			
		current_popup = ISSUE_POPUP_SCENE.instantiate()
		add_child(current_popup) 
		current_popup.setup_issue( issues, issue_id)
		
	else:
		print("ERROR: Dialogue system node is not valid!")

func _on_taskboard_button_pressed() -> void:
	$BackgroundTaskboard/TaskboardButton/TaskboardSound.play() if $BackgroundTaskboard/TaskboardButton.has_node("TaskboardSound") else null
	EventBus.fade_out_robot.emit()
	EventBus.hide_taskboard_arrow.emit()
	
	if is_instance_valid(taskboard_overlay):
		taskboard_overlay.visible = !taskboard_overlay.visible

func _on_manual_button_pressed() -> void:
	manual_sound.play()
	await manual_sound.finished 
	
	if not is_instance_valid(manual_popup_instance):
		manual_popup_instance = MANUAL_POPUP_SCENE.instantiate()
		add_child(manual_popup_instance)
		
	manual_popup_instance.open_manual()
