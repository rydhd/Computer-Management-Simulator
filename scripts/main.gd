extends Node

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_logout_button_pressed() -> void:
	pass # Replace with function body.
