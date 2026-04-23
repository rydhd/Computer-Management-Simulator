extends Node2D # Or whatever node type ComputerDisplay is

func _ready() -> void:
	# Ensure it starts hidden or turned off, if desired
	self.visible = false 
	
	# Connect the EventBus signal to a local function
	EventBus.start_computer_display.connect(_on_computer_display_started)

func _on_computer_display_started() -> void:
	print("Signal received! Switching on the Computer Display.")
	# Show the display, play an animation, or enable processing!
	self.visible = true
	
	# If you have specific setup logic for the display, put it here
	# e.g., $BootUpAnimation.play("boot")
