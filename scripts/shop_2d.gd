extends Node2D
# Shop_2d.gd

# Preload the NPC scene so Godot loads it once when the game starts, 
# improving performance when we instance it later.
const NPC_SCENE = preload("res://scenes/NpcCustomer.tscn")

@onready var npc_spawn_position: Marker2D = $NpcSpawnPoint # Assuming you add a Marker2D in your scene editor
@onready var dialogue_system = $DialogueSystem # Assuming you have a node to manage dialogue UI
@onready var taskboard_overlay = $TaskboardOverlay

# Tracks the current NPC instance
var current_npc: Area2D = null 

func start_npc_dialogue():
	# This function is called when the NPC is ready for dialogue.
	
	print("NPC fade-in finished, starting dialogue!")
	
	if is_instance_valid(dialogue_system):
		# This is the line that calls your DialogueSystem script
		dialogue_system.show_dialogue("Hello, what can I help you with?")
	else:
		print("ERROR: Dialogue system node is not valid!")


# This function name must match the signal connection from your Button!
func _on_button_pressed() -> void:
	print("Bell pressed! Attempting to spawn NPC.")
	
	# Don't spawn a new NPC if one is already present.
	if is_instance_valid(current_npc):
		print("NPC already here, starting dialogue instead.")
		start_npc_dialogue()
		return

	# --- 1. Spawn the NPC ---
	current_npc = NPC_SCENE.instantiate()
	
	# --- 2. Set Scale (if you still need this) ---
	var desired_scale = Vector2(0.3, 0.3) # Or whatever scale you chose
	current_npc.scale = desired_scale
	
	# Add the NPC to the scene tree.
	$NpcLayer.add_child(current_npc)

	# --- 3. Set Position DIRECTLY ---
	# We no longer start off-screen. Set its position directly
	# to the spawn point, since it will be invisible anyway.
	current_npc.global_position = npc_spawn_position.global_position
	
	# --- 4. Start Fade-in and Connect Signal ---
	
	# Call the new fade-in function on the NPC script.
	current_npc.fade_in_and_signal()
	
	# We connect the NPC's NEW signal to our dialogue function.
	# Make sure this matches the signal name in NpcCharacter.gd!
	current_npc.fade_in_complete.connect(start_npc_dialogue)
	
	EventBus.npc_arrived.emit()
	# That's it! No more movement logic needed here.

func _on_taskboard_button_pressed() -> void:
	print("Taskboard Button Pressed!")
	if is_instance_valid(taskboard_overlay):
		# Toggle visibility: if it's hidden, show it; if it's shown, hide it.
		taskboard_overlay.visible = !taskboard_overlay.visible
	else:
		print("ERROR: TaskboardOverlay node not found!")
