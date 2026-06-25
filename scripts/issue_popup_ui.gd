extends CanvasLayer

@onready var description_text: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/RichTextLabel
@onready var clip_button: Button = $PanelContainer/MarginContainer/Button
@onready var click_audio: AudioStreamPlayer = $AudioStreamPlayer # Reference the new node

var current_issue_id: String = ""

func _ready() -> void:
	clip_button.pressed.connect(_on_clip_button_pressed)

func setup_issue(issues: Array, issue_id: String) -> void:
	current_issue_id = issue_id
	
	var formatted_text = "[b]Current Issues:[/b]\n"
	for issue in issues:
		formatted_text += "• " + str(issue) + "\n"
	
	description_text.text = formatted_text

func _on_clip_button_pressed() -> void:
	# 1. Emit your event immediately so the game logic continues
	EventBus.issue_clipped_to_board.emit(current_issue_id)
	
	# 2. Disable the button to prevent spam-clicking
	clip_button.disabled = true
	
	# 3. Play the audio
	if click_audio.stream != null:
		click_audio.play()
		
	# 4. Hide the panel container immediately to provide visual closure
	$PanelContainer.hide()
	
	# 5. Wait for the audio to finish playing, then destroy the scene
	await click_audio.finished
	queue_free()
