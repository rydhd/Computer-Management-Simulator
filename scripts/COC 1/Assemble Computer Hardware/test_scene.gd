extends Control

# --- SCENE REFERENCES ---
@onready var screen_display: ColorRect = $PC/ScreenDisplay
@onready var power_button: TextureButton = $SystemUnit/PowerButton

# --- UPDATED REFERENCES ---
@onready var wall_power_socket: TextureRect = $WallPowerSocket # On the main scene
@onready var switch_sound: AudioStreamPlayer = $SwitchSound # Audio feedback
@onready var cable_sound: AudioStreamPlayer = $CableSound
@onready var boot_sound: AudioStreamPlayer =$BootSound
# --- GAME STATE VARIABLES ---
var is_plugged_into_wall: bool = false
var is_system_running: bool = false

func _ready() -> void:
	# Initial Setup
	screen_display.color = Color.BLACK 
	
	# Connect signals
	power_button.pressed.connect(_on_front_power_button_pressed)

	# Listen for the wall cable
	if wall_power_socket.has_signal("cable_plugged_in"):
		wall_power_socket.cable_plugged_in.connect(_on_wall_power_plugged_in)

func _on_wall_power_plugged_in() -> void:
	is_plugged_into_wall = true
	print("AC Power connected!")
	
	# Play sound when plugged in
	if cable_sound:
		cable_sound.play()

# --- FINAL BOOT LOGIC ---
func _on_front_power_button_pressed() -> void:
	if is_system_running: return # Already on!
	
	# Play button click sound
	if switch_sound:
		switch_sound.play()
	
	# Only check if plugged into the wall
	if is_plugged_into_wall:
		boot_sequence()
	else:
		print("Click! ... Nothing happened. Did you plug it into the wall?")

func boot_sequence() -> void:
	
	boot_sound.play()
	is_system_running = true
	print("BEEP! System is booting...")
	
	# 1. Animate the screen turning on!
	var tween = create_tween()
	# Fade the screen from Black to an "OS" Blue color over 1.5 seconds
	tween.tween_property(screen_display, "color", Color(0.2, 0.5, 0.8), 1.5)
	
	# 2. After the tween finishes, trigger our completion sequence
	tween.finished.connect(_on_boot_complete)

# --- COMPLETION SEQUENCE ---
func _on_boot_complete() -> void:
	print("Level Complete! Updating GlobalState...")
	
	# Mark the current active task as complete in the global state!
	GlobalState.complete_task(GlobalState.current_issue)
	
	# Add a cinematic 2-second delay so the player sees the screen light up
	await get_tree().create_timer(2.0).timeout
	
	# Return the player to the shop scene
	var err = get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
	
	if err != OK:
		push_error("Failed to load shop scene. Check the file path!")
