extends CanvasLayer

@onready var name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var description_text: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/RichTextLabel
@onready var clip_button: Button = $PanelContainer/MarginContainer/VBoxContainer/Button

var current_issue_id: String = ""

func _ready() -> void:
	clip_button.pressed.connect(_on_clip_button_pressed)

# Updated to accept an Array of strings for the 3 issues
func setup_issue(customer_name: String, issues: Array[String], issue_id: String) -> void:
	name_label.text = "Customer: " + customer_name
	current_issue_id = issue_id
	
	# Formatting the 3 issues into a bulleted list for the RichTextLabel
	var formatted_text = "[b]Current Issues:[/b]\n"
	for issue in issues:
		formatted_text += "• " + issue + "\n"
	
	description_text.text = formatted_text

func _on_clip_button_pressed() -> void:
	EventBus.issue_clipped_to_board.emit(current_issue_id)
	queue_free()
