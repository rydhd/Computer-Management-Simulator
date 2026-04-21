# tutorial_manager.gd (Autoload)
extends Node

# Define the sequence of your tutorial
enum TutorialStep {
	START,              # Robot introduces Taskboard, Manual, Bell
	WAITING_FOR_NPC,    # Waiting for the first NPC to show up
	WAITING_FOR_CLIP,   # Waiting for the player to press the "Clip" button
	COMPLETED           # Tutorial is over!
}

var current_step: TutorialStep = TutorialStep.START

func _ready() -> void:
	# Connect to the game events
	EventBus.npc_arrived.connect(_on_npc_arrived)
	EventBus.issue_clipped_to_board.connect(_on_issue_clipped)
	
	## Optional: Start the tutorial after a short delay so the scene loads
	#get_tree().create_timer(1.0).timeout.connect(start_tutorial)

# res://scripts/tutorial_manager.gd

func start_tutorial() -> void:
	if current_step == TutorialStep.START:
		EventBus.trigger_robot_dialogue.emit("Hello!")
		await EventBus.continue_tutorial_dialogue # Waits indefinitely for the player's click
		
		EventBus.trigger_robot_dialogue.emit("I am Chip the robot.")
		await EventBus.continue_tutorial_dialogue
		
		EventBus.trigger_robot_dialogue.emit("I am here to help you manage the store!")
		await EventBus.continue_tutorial_dialogue
		
		EventBus.trigger_robot_dialogue.emit("Let's get started! The first thing you should know is the Bell.")
		await EventBus.continue_tutorial_dialogue
		
		# Trigger our visual cues!
		EventBus.show_bell_arrow.emit()
		EventBus.fade_out_robot.emit() # <--- Tell the robot to fade away
		
		current_step = TutorialStep.WAITING_FOR_NPC
		
# 1. FIX: Ensure there are NO arguments here, to match the shop_2d.gd emit!
func _on_npc_arrived() -> void:
	print("DEBUG: NPC arrived! Current step is: ", current_step)
	
	if current_step == TutorialStep.WAITING_FOR_NPC:
		# We silently advance the state so the Clip button will work!
		current_step = TutorialStep.WAITING_FOR_CLIP
		print("DEBUG: State successfully changed to WAITING_FOR_CLIP!")


func _on_issue_clipped(issue_id: String) -> void:
	print("DEBUG: Clip button clicked! Current step is: ", current_step)
	
	if current_step == TutorialStep.WAITING_FOR_CLIP:
		EventBus.reset_robot_position.emit()
		EventBus.trigger_robot_dialogue.emit("Great job! You've clipped the issue to the board. Click the Taskboard to get to work.")
		
		print("DEBUG: Emitting show_taskboard_arrow now!")
		EventBus.show_taskboard_arrow.emit()
		
		current_step = TutorialStep.COMPLETED
