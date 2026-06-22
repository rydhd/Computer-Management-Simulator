extends Control

# 1. Preload the Manual Popup Scene right next to your other preloads
const NPC_SCENE = preload("res://scenes/NpcCustomer.tscn")
const ISSUE_POPUP_SCENE = preload("res://scenes/issue_popup_ui.tscn")
const MANUAL_POPUP_SCENE = preload("res://scenes/manual_popup.tscn") 
@onready var bell_sound = $BackgroundBell/BellSound
@onready var npc_spawn_position: Control = $NpcSpawnPoint
@onready var dialogue_system = $DialogueSystem
@onready var taskboard_overlay = $TaskboardOverlay
@onready var manual_button: Button = $BackgroundManual/ManualButton 

# Tracks the current instances
var current_npc: Area2D = null 
var current_popup: Node = null
var manual_popup_instance: Node = null 
var is_processing_bell: bool = false

func _ready() -> void:
	# --- BULLETPROOF TUTORIAL OVERRIDE ---
	if GlobalState.completed_tasks.size() > 0:
		TutorialManager.current_step = TutorialManager.TutorialStep.COMPLETED

	# Connect the manual button
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
			
			# Record that Miyamura is completely done
			GlobalState.set_meta("miyamura_finished", true)
		else:
			# If it's not Miyamura's task, it must be Chase's hardware combo
			current_npc.my_name = "Chase"
			
			# Record that Chase is completely done
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

# --- NEW FUNCTION FOR THE OS DIALOGUE ---
func _on_os_install_complete() -> void:
	EventBus.trigger_robot_dialogue.emit("Great job! You successfully installed the Operating System.")
	await EventBus.continue_tutorial_dialogue
	
	EventBus.trigger_robot_dialogue.emit("Open the Taskboard to check off your task and move on to arranging the cables!")
	await EventBus.continue_tutorial_dialogue
	
	# Send the robot away
	EventBus.fade_out_robot.emit()
	
	# Set the meta tag so this congratulation never plays again
	GlobalState.set_meta("os_install_acknowledged", true)

# --- FUNCTION FOR THE POST-HARDWARE DIALOGUE ---
func _on_first_job_complete() -> void:
	EventBus.trigger_robot_dialogue.emit("Great work getting that PC assembled!")
	await EventBus.continue_tutorial_dialogue
	
	EventBus.trigger_robot_dialogue.emit("Open the Taskboard to check off your task and grab your next job!")
	await EventBus.continue_tutorial_dialogue
	
	# Send the robot away
	EventBus.fade_out_robot.emit()
	
	# Mark it true so this congratulation never plays again!
	GlobalState.first_job_acknowledged = true

func _on_bell_button_pressed() -> void:
	# 1. Anti-Spam Lock: If we are already processing a click, ignore this one!
	if is_processing_bell:
		return
		
	# 2. State Check: If an NPC is already here, DO NOTHING!
	if is_instance_valid(current_npc):
		print("An NPC is already here. Help them first!")
		return
		
	# Lock the bell logic now that we've passed the checks
	is_processing_bell = true
	print("Bell pressed! Attempting to spawn NPC.")
	
	# 3. Play the AudioStreamPlayer sound
	$BackgroundBell/BellSound.play()
	
	# --- TELL THE TUTORIAL WE RUNG THE BELL ---
	EventBus.hide_bell_arrow.emit()
	
	# 4. Instantiate the NPC
	current_npc = NPC_SCENE.instantiate()
	current_npc.scale = Vector2(0.3, 0.3) 
	
	# --- UPDATE: Sequential Spawning based on GlobalState ---
	if not GlobalState.has_meta("chase_finished"):
		# If Chase HAS NOT finished his job yet, force Chase to spawn.
		current_npc.my_name = "Chase"
		current_npc.my_id = "task_001_chase"
	else:
		# If Chase HAS finished his job, force Miyamura to spawn next!
		current_npc.my_name = "Miyamura"
		current_npc.my_intro = "Hi! My office computers can't talk to each other. Can you set up our network?"
		current_npc.my_outro = "Thanks! The network is up and running smoothly."
		current_npc.my_issues = ["Set-up Computer Networks"]
		current_npc.my_id = "task_002_network"
	# ------------------------------------------------------------------
	
	$NpcLayer.add_child(current_npc)
	current_npc.global_position = npc_spawn_position.global_position
	
	# 5. Trigger the fade-in animation and WAIT for it to finish
	current_npc.fade_in_and_signal()
	await current_npc.fade_in_complete
	
	# Tell the rest of the game the NPC arrived
	EventBus.npc_arrived.emit()
	
	# 6. Start the dialogue sequence automatically!
	start_npc_dialogue(current_npc.my_intro, current_npc.my_name, current_npc.my_issues, current_npc.my_id)
	
	# Unlock the bell logic so it can be used again in the future
	is_processing_bell = false

func start_npc_dialogue(intro_text: String, customer_name: String, issues: Array, issue_id: String) -> void:
	print("NPC fade-in finished, starting dialogue!")
	
	if is_instance_valid(dialogue_system):
		
		# Build a multi-page array out of the NPC's intro text
		var dialogue_lines: Array[String] = [
			intro_text,
			"Can you fix these for me?"
		]
		
		dialogue_system.start_dialogue(dialogue_lines)
		
		# WAIT FOR THE SIGNAL! 
		# This halts the code until the player clicks through all dialogue pages.
		await dialogue_system.dialogue_finished
		
		# Prevents crashes if the scene was changed while the player was reading
		if not is_inside_tree():
			return 
		
		# --- SPAWN THE UI POPUP ---
		if is_instance_valid(current_popup):
			current_popup.queue_free()
			
		current_popup = ISSUE_POPUP_SCENE.instantiate()
		add_child(current_popup) 
		current_popup.setup_issue( issues, issue_id)
		
	else:
		print("ERROR: Dialogue system node is not valid!")

func _on_taskboard_button_pressed() -> void:
	EventBus.fade_out_robot.emit()
	print("Taskboard Button Pressed!")
	
	# HIDE THE ARROW!
	EventBus.hide_taskboard_arrow.emit()
	
	if is_instance_valid(taskboard_overlay):
		taskboard_overlay.visible = !taskboard_overlay.visible
	else:
		print("ERROR: TaskboardOverlay node not found!")

func _on_manual_button_pressed() -> void:
	print("Manual Button Pressed!")
	
	# Check if the manual is already instanced to save memory.
	# If not, we instantiate it and add it to the scene tree.
	if not is_instance_valid(manual_popup_instance):
		manual_popup_instance = MANUAL_POPUP_SCENE.instantiate()
		add_child(manual_popup_instance)
		
	# Call the public API function we created in manual_popup.gd!
	manual_popup_instance.open_manual()
