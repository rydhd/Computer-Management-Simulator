extends Control # Or Node2D, depending on your root node

@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton
@onready var click_audio: AudioStreamPlayer = $StartAudio # Make sure this matches your node name

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	# Wipe old data so the player starts fresh!
	GlobalState.reset_game_state()
	
	# --- NEW: Start the timer for the Hardware Assembly task! ---
	GlobalState.start_scene_timer()
	
	# Disable the button to prevent double-clicking while the sound plays
	start_button.disabled = true
	
	# Play the audio and wait for it to finish
	if click_audio.stream != null:
		click_audio.play()
		await click_audio.finished
	
	# Now go to the menu
	get_tree().change_scene_to_file("res://scenes/COC 1/Assemble Computer Hardware/computer_menu.tscn")

func _on_back_button_pressed() -> void:
	# Disable the button to prevent double-clicking
	back_button.disabled = true
	
	# Play the audio and wait for it to finish
	if click_audio.stream != null:
		click_audio.play()
		await click_audio.finished
		
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
