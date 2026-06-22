extends CanvasLayer

@onready var description_text: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/RichTextLabel
@onready var clip_button: Button = $PanelContainer/MarginContainer/VBoxContainer/Button

var current_issue_id: String = ""

func _ready() -> void:
	clip_button.pressed.connect(_on_clip_button_pressed)

# FIX: Changed 'Array[String]' to 'Array' so it accepts data from any NPC
func setup_issue(issues: Array, issue_id: String) -> void:
	current_issue_id = issue_id
	
	# Formatting the issues into a bulleted list for the RichTextLabel
	var formatted_text = "[b]Current Issues:[/b]\n"
	for issue in issues:
		# Godot will automatically convert the generic Array items to Strings here
		formatted_text += "• " + str(issue) + "\n"
	
	description_text.text = formatted_text

func _on_clip_button_pressed() -> void:
	EventBus.issue_clipped_to_board.emit(current_issue_id)
	queue_free()
