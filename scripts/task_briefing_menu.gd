extends Control
class_name TaskBriefingMenu

# 1. Define custom signals for our scene to communicate outwards!
signal job_accepted
signal job_declined

@onready var client_name_label: Label = %ClientNameLabel
@onready var issue_description_label: Label = %IssueDescriptionLabel
@onready var accept_button: Button = %AcceptButton
@onready var decline_button: Button = %DeclineButton

func _ready() -> void:
	accept_button.pressed.connect(_on_accept_pressed)
	decline_button.pressed.connect(_on_decline_pressed)

func setup_briefing(client_name: String, issue_desc: String) -> void:
	client_name_label.text = "Client: " + client_name
	issue_description_label.text = "Task: " + issue_desc

func _on_accept_pressed() -> void:
	# Emit the signal to tell whatever spawned this menu that we are ready to play
	job_accepted.emit()
	queue_free() # Destroy the menu

func _on_decline_pressed() -> void:
	job_declined.emit()
	queue_free()
