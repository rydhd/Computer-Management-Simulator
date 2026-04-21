extends Control

# Update our node references to match the new PanelContainer setup
@onready var panel = $PanelContainer
@onready var label = $PanelContainer/Marginb/DialogueLabel

var _text_tween: Tween
var _alpha_tween: Tween

func _ready() -> void:
	visible = false
	modulate.a = 0.0 # Start fully transparent

func show_dialogue(text_to_display: String) -> void:
	# 1. Cancel any old animations if they are still running
	if _alpha_tween and _alpha_tween.is_valid(): _alpha_tween.kill()
	if _text_tween and _text_tween.is_valid(): _text_tween.kill()
	
	# 2. Prepare the text and make the node visible
	label.text = text_to_display
	label.visible_ratio = 0.0 # Hide all text characters initially
	visible = true
	
	# 3. Fade the whole dialogue box in
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(self, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	
	# 4. Typewriter effect (Same math as your TutorialRobot!)
	var type_duration: float = text_to_display.length() * 0.03
	_text_tween = create_tween()
	_text_tween.tween_property(label, "visible_ratio", 1.0, type_duration)

func hide_dialogue() -> void:
	# Fade the dialogue box out, then hide it completely
	if _alpha_tween and _alpha_tween.is_valid(): _alpha_tween.kill()
	
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	_alpha_tween.tween_callback(func(): visible = false)
	
