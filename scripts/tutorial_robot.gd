# res://scripts/tutorial_robot.gd
extends Node2D

@onready var speech_bubble: PanelContainer = $DialogueAnchor/SpeechBubble
@onready var robot_text: Label = $DialogueAnchor/SpeechBubble/MarginContainer/RobotText
@onready var blip_sound: AudioStreamPlayer2D = $BlipSound

@export var typing_speed: float = 0.03 

var _alpha_tween: Tween
var _text_tween: Tween
var is_typing: bool = false 

# NEW: Store the original position
var default_position: Vector2 

func _ready() -> void:
	default_position = global_position 
	
	visible = false 
	speech_bubble.visible = false
	speech_bubble.modulate.a = 0.0 
	
	EventBus.trigger_robot_dialogue.connect(_on_robot_speak)
	EventBus.fade_out_robot.connect(_on_fade_out)
	EventBus.fade_out_robot.connect(_on_fade_out_robot)

func _on_fade_out_robot() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3) # Fast 0.3 second fade out
	tween.tween_callback(hide) # Hide it completely once transparent
func _on_reset_position() -> void:
	global_position = default_position
# NEW: Function to instantly teleport the robot before it fades in
func _on_move_robot(new_pos: Vector2) -> void:
	global_position = new_pos
func fade_in_robot() -> void:
	# 1. Make the robot visible right before the animation starts!
	visible = true
	
	# 2. Reset the starting state to be invisible and tiny
	modulate.a = 0.0
	scale = Vector2.ZERO 
	
	# 3. Create the parallel tween for the pop-up effect
	var popup_tween: Tween = create_tween()
	popup_tween.set_parallel(true)
	
	popup_tween.tween_property(self, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	popup_tween.tween_property(self, "scale", Vector2.ONE, 0.5) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
func _on_robot_speak(dialogue_text: String) -> void:
	# 1. NEW: Check if the robot is hidden, and pop it in if it is!
	if not visible:
		fade_in_robot()
		
	# 2. Cancel old tweens
	if _alpha_tween and _alpha_tween.is_valid(): _alpha_tween.kill()
	if _text_tween and _text_tween.is_valid(): _text_tween.kill()

	robot_text.visible_ratio = 0.0
	robot_text.text = dialogue_text
	speech_bubble.visible = true
	is_typing = true
	
	# Start the sound!
	blip_sound.play()
	
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(speech_bubble, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	
	var type_duration: float = dialogue_text.length() * typing_speed
	_text_tween = create_tween()
	_text_tween.tween_property(robot_text, "visible_ratio", 1.0, type_duration)
	
	# When the tween naturally finishes, call our finished function
	_text_tween.tween_callback(_on_typing_finished)

# Called when typing finishes naturally OR when skipped via click
func _on_typing_finished() -> void:
	is_typing = false
	blip_sound.stop() # Sync: Stop the sound the exact moment text finishes

# Listen for player clicks anywhere on the screen
func _input(event: InputEvent) -> void:
	# If the bubble is visible and the player left-clicks
	if speech_bubble.visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Prevent this click from accidentally clicking things behind the UI (like PC parts)
		get_viewport().set_input_as_handled() 
		
		if is_typing:
			# SCENARIO 1: Still typing. Skip animation.
			if _text_tween and _text_tween.is_valid():
				_text_tween.kill() # Stop the typewriter
			robot_text.visible_ratio = 1.0 # Show all text instantly
			_on_typing_finished() # Stop the sound and update state
		else:
			# SCENARIO 2: Done typing. Advance to next dialogue.
			hide_dialogue()
			EventBus.continue_tutorial_dialogue.emit() # Tell the Manager we are ready!

func hide_dialogue() -> void:
	if _alpha_tween and _alpha_tween.is_valid(): _alpha_tween.kill()
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.3)
	_alpha_tween.tween_callback(func(): speech_bubble.visible = false)
	
func _on_fade_out() -> void:
	# Create a tween to fade the entire robot and its children out
	var fade_tween: Tween = create_tween()
	
	# Fade the entire Node2D's alpha to 0 over 0.5 seconds
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	
	# Once it is fully transparent, hide it so it doesn't consume UI clicks
	fade_tween.tween_callback(func(): visible = false)
