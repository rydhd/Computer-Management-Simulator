extends Area2D

# 1. Update signal to pass an Array instead of a single String
signal fade_in_complete(intro_text: String, customer_name: String, issues: Array[String], issue_id: String)

const FADE_IN_DURATION = 1.0

var my_intro: String = "Hello there! I'm Gelo. I'm trying to build my first PC but I have no idea what I'm doing."
var my_name: String = "Gelo"

# 2. Store the 3 issues in an Array
var my_issues: Array[String] = [
	"Assemble computer hardware",
	"Install OS",
	"Cable Management"
]

var my_id: String = "task_001_gelo"

func _ready() -> void:
	# NEW: Listen for the clipping event
	EventBus.issue_clipped_to_board.connect(_on_issue_clipped_to_board)
func fade_in_and_signal() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), FADE_IN_DURATION)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	print("NPC fade-in complete.")
	# 3. Emit the array of issues
	fade_in_complete.emit(my_intro, my_name, my_issues, my_id)
	
func _on_issue_clipped_to_board(issue_id: String) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0) # Fade to 0 alpha over 1 second
	tween.tween_callback(queue_free) # Delete the NPC safely after fading
