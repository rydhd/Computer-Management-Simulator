extends Control # Or Node2D, depending on your root node

@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	# Wipe old data so the player starts fresh!
	GlobalState.reset_game_state()
	
	# Now go to the menu
	get_tree().change_scene_to_file("res://scenes/COC 1/Assemble Computer Hardware/computer_menu.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
