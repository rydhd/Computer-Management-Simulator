extends Node
@onready var button_sound: AudioStreamPlayer = $ButtonAudio

func _on_play_button_pressed() -> void:
	button_sound.play()
	# Wait for the audio track to finish completely
	await button_sound.finished 
	get_tree().change_scene_to_file("res://scenes/cutscene.tscn")

func _on_quit_button_pressed() -> void:
	button_sound.play()
	# Wait for the audio track to finish completely
	await button_sound.finished 
	get_tree().quit()

func _on_logout_button_pressed() -> void:
	button_sound.play()
	# No scene change here, so no await is needed (unless you add code below it)
	pass
