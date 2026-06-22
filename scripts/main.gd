extends Node

func _on_play_button_pressed() -> void:
	# Change this path to point to your new cutscene scene
	get_tree().change_scene_to_file("res://scenes/cutscene.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_logout_button_pressed() -> void:
	pass # Replace with function body.
