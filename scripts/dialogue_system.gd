extends Control

# Update our node references to match the new PanelContainer setup
@onready var panel = $PanelContainer
@onready var label = $PanelContainer/Marginb/DialogueLabel

var _text_tween: Tween
var _alpha_tween: Tween

# NEW: Tracking variables for our dialogue queue
var dialogue_queue: Array[String] = []
var is_typing: bool = false
signal dialogue_finished

func _ready() -> void:
	visible = false
	modulate.a = 0.0 # Start fully transparent

# NEW: Pass an array of strings to have a multi-page conversation!
func start_dialogue(texts_to_display: Array[String]) -> void:
	if texts_to_display.is_empty():
		return
		
	dialogue_queue = texts_to_display
	
	if _alpha_tween and _alpha_tween.is_valid(): _alpha_tween.kill()
	visible = true
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(self, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	
	_show_current_line()

func show_dialogue(text_to_display: String) -> void:
	self.visible = true
	# Automatically split long sentences into multiple dialogue pages!
	# We add a hidden "|" marker after punctuation marks, then split the string.
	var formatted_text = text_to_display.replace("! ", "!|").replace(". ", ".|").replace("? ", "?|")
	var split_array = formatted_text.split("|")
	
	var final_queue: Array[String] = []
	for sentence in split_array:
		if sentence.strip_edges() != "":
			final_queue.append(sentence.strip_edges())
			
	# Send our newly sliced array to the queue system
	start_dialogue(final_queue)

func hide_dialogue() -> void:
	# Fallback: allows older scripts like shop_2d.gd to manually hide the dialogue
	dialogue_queue.clear()
	_close_dialogue()

func _show_current_line() -> void:
	# If no more text, fade out and close!
	if dialogue_queue.is_empty():
		_close_dialogue()
		return
		
	if _text_tween and _text_tween.is_valid(): _text_tween.kill()
	
	var current_text = dialogue_queue[0]
	label.text = current_text
	label.visible_ratio = 0.0
	is_typing = true
	
	var type_duration: float = current_text.length() * 0.03
	_text_tween = create_tween()
	_text_tween.tween_property(label, "visible_ratio", 1.0, type_duration)
	_text_tween.finished.connect(func(): is_typing = false)

func _close_dialogue() -> void:
	if _alpha_tween and _alpha_tween.is_valid(): _alpha_tween.kill()
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	_alpha_tween.finished.connect(func():
		visible = false
		dialogue_finished.emit()
	)

# NEW: This intercepts mouse clicks while the dialogue box is visible
func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled() # Prevent clicking objects behind UI
		
		if is_typing:
			# Skip typewriter effect and instantly show all text
			if _text_tween and _text_tween.is_valid():
				_text_tween.kill()
			label.visible_ratio = 1.0
			is_typing = false
		else:
			# Move to the next line
			if not dialogue_queue.is_empty():
				dialogue_queue.pop_front()
			_show_current_line()
