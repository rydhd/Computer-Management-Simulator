# dialogue_system.gd
extends Control

@onready var label = $VBoxContainer/DialogueLabel 

func _ready():
	visible = false

func show_dialogue(text_to_display: String):
	label.text = text_to_display
	visible = true

func hide_dialogue():
	visible = false
