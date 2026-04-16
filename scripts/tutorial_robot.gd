extends Node2D

@onready var speech_bubble: PanelContainer = $DialogueAnchor/SpeechBubble
@onready var robot_text: Label = $DialogueAnchor/SpeechBubble/MarginContainer/RobotText
@onready var blip_sound: AudioStreamPlayer2D = $BlipSound

# You can adjust this in the inspector. Lower is faster.
@export var typing_speed: float = 0.03 

func _ready() -> void:
	# Hide the bubble by default when the scene loads
	speech_bubble.visible = false
	speech_bubble.modulate.a = 0.0 # Make it fully transparent
	
	# Connect to the EventBus!
	EventBus.trigger_robot_dialogue.connect(_on_robot_speak)

func _on_robot_speak(dialogue_text: String) -> void:
	# 1. Reset the text reveal ratio BEFORE setting the text
	robot_text.visible_ratio = 0.0
	robot_text.text = dialogue_text
	
	# Play the blip sound
	blip_sound.play()
	
	# Make the bubble visible
	speech_bubble.visible = true
	
	# 2. Fade in the bubble (Alpha Tween)
	var alpha_tween: Tween = create_tween()
	alpha_tween.tween_property(speech_bubble, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	
	# 3. Typewriter Effect (Text Tween)
	# Calculate how long the typing animation should take based on the string length
	var type_duration: float = dialogue_text.length() * typing_speed
	
	var text_tween: Tween = create_tween()
	# visible_ratio goes from 0.0 (hidden) to 1.0 (fully visible)
	text_tween.tween_property(robot_text, "visible_ratio", 1.0, type_duration)
	
	# 4. Smart Auto-Hide
	# Wait for the typing to finish, PLUS an extra 3 seconds for the player to read it
	var total_time_on_screen: float = type_duration + 3.0
	get_tree().create_timer(total_time_on_screen).timeout.connect(hide_dialogue)

func hide_dialogue() -> void:
	# Only hide if it's currently fully visible (prevents double-firing issues)
	if speech_bubble.modulate.a >= 0.9:
		var tween: Tween = create_tween()
		tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): speech_bubble.visible = false)
		
