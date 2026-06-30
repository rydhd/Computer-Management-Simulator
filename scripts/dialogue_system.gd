extends Control

# Update our node references to match the new PanelContainer setup
@onready var panel = $PanelContainer
@onready var label = $PanelContainer/Marginb/DialogueLabel

# --- CONTINUE PROMPT REFERENCES ---
@onready var continue_prompt: Label = $PanelContainer/ContinuePrompt
var prompt_tween: Tween # Used to make the text blink

var _text_tween: Tween
var _alpha_tween: Tween

# Tracking variables for our dialogue queue
var dialogue_queue: Array[String] = []
var is_typing: bool = false
signal dialogue_finished

func _ready() -> void:
	visible = false
	modulate.a = 0.0 # Start fully transparent
	
	# Make sure the prompt is hidden when the game starts
	if continue_prompt:
		continue_prompt.hide()

# Pass an array of strings to have a multi-page conversation!
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
	# Fallback: allows older scripts to manually hide the dialogue
	dialogue_queue.clear()
	_close_dialogue()

func _show_current_line() -> void:
	# If no more text, fade out and close!
	if dialogue_queue.is_empty():
		_close_dialogue()
		return
		
	if _text_tween and _text_tween.is_valid(): _text_tween.kill()
	
	# --- PROMPT LOGIC: Hide the prompt while typing ---
	if prompt_tween and prompt_tween.is_valid():
		prompt_tween.kill()
	if continue_prompt:
		continue_prompt.hide()
		continue_prompt.modulate.a = 1.0 # Reset opacity back to full
	# --------------------------------------------------
	
	var current_text = dialogue_queue[0]
	label.text = current_text
	label.visible_ratio = 0.0
	is_typing = true
	
	var type_duration: float = current_text.length() * 0.03
	_text_tween = create_tween()
	_text_tween.tween_property(label, "visible_ratio", 1.0, type_duration)
	
	# Connect to our new function instead of just setting is_typing to false
	_text_tween.finished.connect(_on_typing_finished)

# --- NEW: Helper function to trigger the blinking prompt ---
func _on_typing_finished() -> void:
	is_typing = false
	
	if continue_prompt:
		continue_prompt.show()
		
		# Create a looping tween to make it pulse/blink smoothly
		if prompt_tween and prompt_tween.is_valid():
			prompt_tween.kill()
		prompt_tween = create_tween().set_loops()
		prompt_tween.tween_property(continue_prompt, "modulate:a", 0.2, 0.5)
		prompt_tween.tween_property(continue_prompt, "modulate:a", 1.0, 0.5)

func _close_dialogue() -> void:
	if _alpha_tween and _alpha_tween.is_valid(): _alpha_tween.kill()
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	_alpha_tween.finished.connect(func():
		visible = false
		dialogue_finished.emit()
	)

# This intercepts mouse clicks while the dialogue box is visible
func _input(event: InputEvent) -> void:
	# If the dialogue is visible and the player left-clicks...
	if visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# BULLETPROOF FIX: Stop the click from passing through the UI!
		get_viewport().set_input_as_handled()
		
		if is_typing:
			# If the text is still animating, instantly finish typing it
			if _text_tween and _text_tween.is_valid(): 
				_text_tween.kill()
			label.visible_ratio = 1.0
			
			# Call our new function to immediately show the blinking prompt!
			_on_typing_finished() 
			
		else:
			# CRITICAL FIX: Remove the sentence we just read from the front of the line!
			dialogue_queue.pop_front()
			
			# Now show whatever is next in line
			_show_current_line()
