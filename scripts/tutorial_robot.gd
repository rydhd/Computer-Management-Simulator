extends Node2D

@onready var speech_bubble: PanelContainer = $DialogueAnchor/SpeechBubble
@onready var robot_text: Label = $DialogueAnchor/SpeechBubble/MarginContainer/RobotText
@onready var blip_sound: AudioStreamPlayer2D = $BlipSound

func _ready() -> void:
	# Hide the bubble by default when the scene loads
	speech_bubble.visible = false
	speech_bubble.modulate.a = 0.0 # Make it fully transparent
	
	# Connect to the EventBus! This is where the magic happens.
	EventBus.trigger_robot_dialogue.connect(_on_robot_speak)

func _on_robot_speak(dialogue_text: String) -> void:
	# Update the text
	robot_text.text = dialogue_text
	
	# Play a sound
	blip_sound.play()
	
	# Animate the speech bubble appearing using Godot 4 Tweens
	speech_bubble.visible = true
	var tween: Tween = create_tween()
	
	# Fade in the bubble over 0.3 seconds
	tween.tween_property(speech_bubble, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	
	# Optional: Auto-hide the bubble after a few seconds
	# If your tutorial requires them to read it before acting, you might 
	# want to remove this timer and let the next state clear it.
	get_tree().create_timer(5.0).timeout.connect(hide_dialogue)

func hide_dialogue() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): speech_bubble.visible = false)
