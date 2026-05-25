extends Area2D
class_name NPCCustomer

# 1. Update signal to pass an Array instead of a single String
signal fade_in_complete(intro_text: String, customer_name: String, issues: Array[String], issue_id: String)

const FADE_IN_DURATION: float = 1.0

# 2. Expose variables to the Inspector! Now this script works for ANY customer.
@export_category("Customer Data")
@export var my_name: String = "Gelo"
@export_multiline var my_intro: String = "Hello there! I'm Gelo. I'm trying to build my first PC but I have no idea what I'm doing."
# --- NEW: Add an outro message for when the task is finished ---
@export_multiline var my_outro: String = "Thank you so much! My PC is running perfectly now. Here is your payment!"

@export var my_issues: Array[String] = [
	"Assemble computer hardware",
	"Install OS",
	"Cable Management"
]
@export var my_id: String = "task_001_gelo"

func _ready() -> void:
	# Listen for the clipping event. 
	# It's good practice to ensure we don't double-connect!
	if not EventBus.issue_clipped_to_board.is_connected(_on_issue_clipped_to_board):
		EventBus.issue_clipped_to_board.connect(_on_issue_clipped_to_board)

func fade_in_and_signal() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	
	# Color.WHITE is a clean, built-in constant for Color(1, 1, 1, 1)
	tween.tween_property(self, "modulate", Color.WHITE, FADE_IN_DURATION)
	
	# 3. Use 'await' to pause this function's execution until the tween is done.
	await tween.finished
	
	print("NPC '%s' fade-in complete." % my_name)
	# Emit the array of issues right here! No extra function needed.
	fade_in_complete.emit(my_intro, my_name, my_issues, my_id)

func _on_issue_clipped_to_board(issue_id: String) -> void:
	# CRITICAL FIX: Only fade out if the clipped issue belongs to THIS NPC.
	if issue_id != my_id:
		return
		
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0) # Fade to 0 alpha over 1 second
	tween.tween_callback(queue_free) # Delete the NPC safely after fading
