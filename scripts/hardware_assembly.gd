extends Node2D


func _on_button_pressed() -> void:
	# Make sure you create a 3D scene and update this path!
	var error = get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
	
	if error != OK:
		print("ERROR: Could not change scene. Check the file path.")
