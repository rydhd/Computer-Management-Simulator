extends Node2D
# Shop_2d.gd

# Preload the NPC scene so Godot loads it once when the game starts, 
# improving performance when we instance it later.
const NPC_SCENE = preload("res://scenes/NpcCustomer.tscn")
const ISSUE_POPUP_SCENE = preload("res://scenes/issue_popup_ui.tscn")

@onready var npc_spawn_position: Marker2D = $NpcSpawnPoint # Assuming you add a Marker2D in your scene editor
@onready var dialogue_system = $DialogueSystem # Assuming you have a node to manage dialogue UI
@onready var taskboard_overlay = $TaskboardOverlay

# Tracks the current NPC instance
var current_npc: Area2D = null 

func _ready() -> void:
	# Add a short delay so the player can orient themselves 
	# when the scene loads before the robot starts talking.
	get_tree().create_timer(1.0).timeout.connect(TutorialManager.start_tutorial)

# UPDATE: Function now expects an Array for the issues!
func start_npc_dialogue(intro_text: String, customer_name: String, issues: Array, issue_id: String) -> void:
	print("NPC fade-in finished, starting dialogue!")
	
	if is_instance_valid(dialogue_system):
		# Show the NPC's specific intro text
		dialogue_system.show_dialogue(intro_text)
		
		# Wait for 2.5 seconds so the player can read it safely in Godot 4
		await get_tree().create_timer(2.5).timeout
		
		# Hide the dialogue box
		dialogue_system.hide_dialogue()
		
		# --- 3. SPAWN THE UI POPUP ---
		# Create a new instance of your popup scene
		var popup = ISSUE_POPUP_SCENE.instantiate()
		
		# Add it to the shop scene tree so it renders on screen
		add_child(popup) 
		
		# Call your custom function to populate the text!
		# FIX: Changed "name" to "customer_name" to match the function parameter
		popup.setup_issue(customer_name, issues, issue_id)
		
	else:
		print("ERROR: Dialogue system node is not valid!")

# This function name must match the signal connection from your Button!
func _on_button_pressed() -> void:
	print("Bell pressed! Attempting to spawn NPC.")
	
	# Don't spawn a new NPC if one is already present.
	if is_instance_valid(current_npc):
		print("NPC already here, starting dialogue instead.")
		
		# THE FIX: Grab the variables directly from the current_npc and pass them in!
		start_npc_dialogue(current_npc.my_intro, current_npc.my_name, current_npc.my_issues, current_npc.my_id)
		return

	# --- 1. Spawn the NPC ---
	current_npc = NPC_SCENE.instantiate()
	
	# --- 2. Set Scale (if you still need this) ---
	var desired_scale = Vector2(0.3, 0.3) 
	current_npc.scale = desired_scale
	
	# Add the NPC to the scene tree.
	$NpcLayer.add_child(current_npc)

	# --- 3. Set Position DIRECTLY ---
	current_npc.global_position = npc_spawn_position.global_position
	
	# --- 4. Start Fade-in and Connect Signal ---
	current_npc.fade_in_and_signal()
	current_npc.fade_in_complete.connect(start_npc_dialogue)
	
	EventBus.npc_arrived.emit()

# shop_2d.gd
func _on_taskboard_button_pressed() -> void:
	EventBus.fade_out_robot.emit()
	print("Taskboard Button Pressed!")
	
	# HIDE THE ARROW!
	EventBus.hide_taskboard_arrow.emit()
	
	if is_instance_valid(taskboard_overlay):
		taskboard_overlay.visible = !taskboard_overlay.visible
	else:
		print("ERROR: TaskboardOverlay node not found!")
