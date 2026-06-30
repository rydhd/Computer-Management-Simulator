extends Control

@onready var button_sound: AudioStreamPlayer = $ButtonSound

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_texture_button_2_pressed() -> void:
	pass 

func _on_flashdrive_pressed() -> void:
	# 1. Disable the button instantly so they can't double-click it
	$BootPriority/MarginContainer/VBoxContainer/Flashdrive.disabled = true
	
	# 2. Play the sound and wait for it to finish
	button_sound.play()
	await button_sound.finished
	
	# 3. Change the scene
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/COC 1/Installing OS/windows_installation_screen.tscn")
