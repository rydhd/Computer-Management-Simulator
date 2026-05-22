extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_start_button_pressed() -> void:
	# Now go to the menu
	get_tree().change_scene_to_file("res://scenes/COC 1/Installing OS/installing_os.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
