extends Control
# Shop_2d.gd

# 1. Preload the Manual Popup Scene right next to your other preloads
const NPC_SCENE = preload("res://scenes/NpcCustomer.tscn")
const ISSUE_POPUP_SCENE = preload("res://scenes/issue_popup_ui.tscn")
const MANUAL_POPUP_SCENE = preload("res://scenes/manual_popup.tscn") # <--- ADD THIS

@onready var npc_spawn_position: Control = $NpcSpawnPoint
@onready var dialogue_system = $DialogueSystem
@onready var taskboard_overlay = $TaskboardOverlay
@onready var manual_button: Button = $BackgroundManual/ManualButton # <--- ADD THIS

# Tracks the current instances
var current_npc: Area2D = null 
var current_popup: Node = null
var manual_popup_instance: Node = null # <--- ADD THIS to keep track of the manual

func _ready() -> void:
	# Add a short delay so the player can orient themselves 
	get_tree().create_timer(1.0).timeout.connect(TutorialManager.start_tutorial)
	
	# 2. Connect the manual button signal via code 
	# (Since it wasn't connected in the .tscn file)
	manual_button.pressed.connect(_on_manual_button_pressed)

func _on_bell_button_pressed() -> void:
	print("Bell pressed! Attempting to spawn NPC.")
	
	if is_instance_valid(current_npc):
		start_npc_dialogue(current_npc.my_intro, current_npc.my_name, current_npc.my_issues, current_npc.my_id)
		return
		
	current_npc = NPC_SCENE.instantiate()
	current_npc.scale = Vector2(0.3, 0.3) 
	$NpcLayer.add_child(current_npc)
	current_npc.global_position = npc_spawn_position.global_position
	
	# 1. CONNECT FIRST! Tell Godot to listen for the signal.
	current_npc.fade_in_complete.connect(_on_npc_fade_in_complete)
	
	# 2. TRIGGER SECOND! Now that we are listening, start the fade.
	current_npc.fade_in_and_signal()
	
	EventBus.npc_arrived.emit()


func _on_npc_fade_in_complete() -> void:
	# Ensure the NPC still exists when the fade finishes
	if is_instance_valid(current_npc):
		
		# 3. DISCONNECT IMMEDIATELY! Prevent memory leaks and double-firing.
		if current_npc.fade_in_complete.is_connected(_on_npc_fade_in_complete):
			current_npc.fade_in_complete.disconnect(_on_npc_fade_in_complete)
			
		# Start the dialogue
		start_npc_dialogue(current_npc.my_intro, current_npc.my_name, current_npc.my_issues, current_npc.my_id)
# UPDATE: Function now expects an Array for the issues!
func start_npc_dialogue(intro_text: String, customer_name: String, issues: Array, issue_id: String) -> void:
	print("NPC fade-in finished, starting dialogue!")
	
	if is_instance_valid(dialogue_system):
		dialogue_system.show_dialogue(intro_text)
		
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
		current_popup.setup_issue(customer_name, issues, issue_id)
		
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


# 3. Replace your empty _on_manual_button_pressed function with this:
func _on_manual_button_pressed() -> void:
	print("Manual Button Pressed!")
	
	# Check if the manual is already instanced to save memory. 
	# If not, we instantiate it and add it to the scene tree.
	if not is_instance_valid(manual_popup_instance):
		manual_popup_instance = MANUAL_POPUP_SCENE.instantiate()
		add_child(manual_popup_instance)
		
	# Call the public API function we created in manual_popup.gd!
	manual_popup_instance.open_manual()
