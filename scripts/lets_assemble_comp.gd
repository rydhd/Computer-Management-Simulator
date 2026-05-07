extends Control # Or Node2D, depending on your root node

@onready var start_button: Button = %StartButton
@onready var begin_button: Button = %BeginButton

func _ready() -> void:
	# Make sure the Begin button is active when the scene loads
	if begin_button:
		begin_button.disabled = false
		
		# Optional: If you want to connect the signal purely in code:
		# begin_button.pressed.connect(_on_begin_button_pressed)

func _on_start_button_pressed() -> void:
	# Wipe old data so the player starts fresh!
	GlobalState.reset_game_state()
	
	# Now go to the menu
	get_tree().change_scene_to_file("res://scenes/computer_menu.tscn")
func _on_begin_button_pressed() -> void:
	print("Moving to Hardware Assembly!")
	get_tree().change_scene_to_file("res://scenes/hardware_assembly.tscn")
