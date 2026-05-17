extends Control

# --- SCENE REFERENCES ---
@onready var screen_display: ColorRect = $PC/ScreenDisplay
@onready var power_button: TextureButton = $SystemUnit/PowerButton
@onready var rotate_to_back_button: TextureButton = $RotateToBackButton

# Back Panel Popup
@onready var back_pc_popup: ColorRect = $BackOfPC_Popup
@onready var psu_switch: TextureButton = $BackOfPC_Popup/ZoomedBackPanel/PSUSwitch
@onready var close_popup_button: Button = $BackOfPC_Popup/ZoomedBackPanel/CloseButton
@onready var wall_power_socket: Control = $BackOfPC_Popup/ZoomedBackPanel/WallPowerSocket

# --- GAME STATE VARIABLES ---
var is_plugged_into_wall: bool = false
var is_psu_switch_on: bool = false
var is_system_running: bool = false

func _ready() -> void:
	# Initial Setup
	screen_display.color = Color.BLACK 
	back_pc_popup.hide()
	
	# Connect signals
	power_button.pressed.connect(_on_front_power_button_pressed)
	psu_switch.pressed.connect(_on_psu_switch_pressed)
	close_popup_button.pressed.connect(_on_close_popup)
	
	# Connect the arrow button to our show_back_panel function
	rotate_to_back_button.pressed.connect(show_back_panel)
	
	# Listen for the wall cable
	if wall_power_socket.has_signal("cable_plugged_in"):
		wall_power_socket.cable_plugged_in.connect(_on_wall_power_plugged_in)


# --- BACK PANEL LOGIC ---
func show_back_panel() -> void:
	back_pc_popup.show()

func _on_close_popup() -> void:
	back_pc_popup.hide()

func _on_wall_power_plugged_in() -> void:
	is_plugged_into_wall = true
	print("AC Power connected!")

func _on_psu_switch_pressed() -> void:
	if not is_plugged_into_wall:
		print("Nothing happened... the wall cable isn't plugged in!")
		return
		
	is_psu_switch_on = !is_psu_switch_on # Toggle switch
	print("PSU Switch flipped to: ", is_psu_switch_on)


# --- FINAL BOOT LOGIC ---
func _on_front_power_button_pressed() -> void:
	if is_system_running: return # Already on!
	
	if is_plugged_into_wall and is_psu_switch_on:
		boot_sequence()
	else:
		print("Click! ... Nothing happened. Did you check the back?")

func boot_sequence() -> void:
	is_system_running = true
	print("BEEP! System is booting...")
	
	# 1. Animate the screen turning on!
	var tween = create_tween()
	# Fade the screen from Black to an "OS" Blue color over 1.5 seconds
	tween.tween_property(screen_display, "color", Color(0.2, 0.5, 0.8), 1.5)
	
	# 2. After the tween finishes, trigger our completion sequence
	tween.finished.connect(_on_boot_complete)

# --- NEW: COMPLETION SEQUENCE ---
func _on_boot_complete() -> void:
	print("Level Complete! Updating GlobalState...")
	
	# 1. Mark the current active task as complete in the global state!
	GlobalState.complete_task(GlobalState.current_issue)
	
	# 2. Add a cinematic 2-second delay so the player sees the screen light up
	# 'await' is a fantastic Godot 4 feature to pause execution briefly without complex timers!
	await get_tree().create_timer(2.0).timeout
	
	# 3. Return the player to the shop scene
	var err = get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
	
	# Safety check just in case the path is wrong
	if err != OK:
		push_error("Failed to load shop scene. Check the file path!")
