extends Control

# --- UI REFERENCES ---
@onready var cable_tray: Control = $CableTray
@onready var psu_drop_zone: Control = $SystemUnit/PSUDropZone
@onready var system_unit_rect: TextureRect = $SystemUnit
@export var completed_system_unit_texture: Texture2D 
@onready var complete_button: Button = $CompleteButton

# --- NEW: Fixed Overlay References ---
# Point to the PanelContainer to show/hide the dark background
@onready var instruction_overlay: PanelContainer = $PanelContainer
# Point to the Label inside it to change the text
@onready var instruction_prompt: Label = $PanelContainer/InstructionPrompt

# --- POPUP REFERENCES ---
@onready var mobo_button: TextureButton = $SystemUnit/MoboButton
@onready var mobo_zoom_popup: ColorRect = $MoboZoomPopup
@onready var close_zoom_button: TextureButton = $MoboZoomPopup/ZoomedMoboVisual/CloseButton

@onready var gpu_button: TextureButton = $SystemUnit/GpuButton
@onready var gpu_zoom_popup: ColorRect = $GpuZoomPopup
@onready var close_gpu_button: TextureButton = $GpuZoomPopup/ZoomedGpuVisual/CloseGpuButton

# --- TASK LIST REFERENCES ---
@onready var task_psu: CheckBox = $TaskOverlay/PanelContainer/VBoxContainer/TaskPSU
@onready var task_24pin: CheckBox = $TaskOverlay/PanelContainer/VBoxContainer/Task24Pin
@onready var task_8pin: CheckBox = $TaskOverlay/PanelContainer/VBoxContainer/Task8Pin
@onready var task_6pin: CheckBox = $TaskOverlay/PanelContainer/VBoxContainer/Task6Pin

# --- SOCKET REFERENCES ---
@onready var socket_24pin = $MoboZoomPopup/ZoomedMoboVisual/MoboSocket_24Pin
@onready var socket_8pin = $MoboZoomPopup/ZoomedMoboVisual/MoboSocket_8Pin
@onready var socket_6pin = $GpuZoomPopup/ZoomedGpuVisual/GpuSocket_6Pin

# --- NEW: AUDIO REFERENCE ---
@onready var plug_sound: AudioStreamPlayer = $PlugSound

# --- TRACKING VARIABLES ---
@export var total_cables_needed: int = 3 
var current_cables_connected: int = 0


func _ready() -> void:
	cable_tray.hide()
	mobo_zoom_popup.hide()
	gpu_zoom_popup.hide() 
	complete_button.hide()
	
	# --- NEW: Show starting instructions ---
	if instruction_overlay and instruction_prompt:
		instruction_prompt.text = "Drag the Power Supply Unit (PSU) into the case."
		instruction_overlay.show()
	
	# Connect existing MOBO signals
	psu_drop_zone.psu_installed.connect(_on_psu_installed)
	mobo_button.pressed.connect(_on_mobo_clicked)
	close_zoom_button.pressed.connect(_on_close_zoom_clicked)
	
	# Connect Sockets individually to update specific tasks
	if socket_24pin:
		socket_24pin.cable_plugged_in.connect(_on_24pin_plugged)
	if socket_8pin:
		socket_8pin.cable_plugged_in.connect(_on_8pin_plugged)
	if socket_6pin:
		socket_6pin.cable_plugged_in.connect(_on_6pin_plugged)

# --- PSU LOGIC ---
func _on_psu_installed() -> void:
	cable_tray.show()
	
	# --- NEW: Update the instruction prompt ---
	if instruction_overlay and instruction_prompt:
		instruction_prompt.text = "Click the Motherboard or GPU to connect the wires!"
		instruction_overlay.show()
	
	if task_psu:
		task_psu.button_pressed = true

# --- POPUP LOGIC ---
func _on_mobo_clicked() -> void:
	mobo_zoom_popup.show()
	# Hide the instruction overlay since they figured out what to do
	if instruction_overlay:
		instruction_overlay.hide()

func _on_close_zoom_clicked() -> void:
	mobo_zoom_popup.hide()

func _on_gpu_button_pressed() -> void:
	gpu_zoom_popup.show()
	# Hide the instruction overlay since they figured out what to do
	if instruction_overlay:
		instruction_overlay.hide()

func _on_close_gpu_button_pressed() -> void:
	gpu_zoom_popup.hide()

# --- SPECIFIC CABLE LOGIC ---
func _on_24pin_plugged() -> void:
	task_24pin.button_pressed = true 
	_increment_progress()

func _on_8pin_plugged() -> void:
	task_8pin.button_pressed = true
	_increment_progress()

func _on_6pin_plugged() -> void:
	task_6pin.button_pressed = true
	_increment_progress()

# --- OVERALL PROGRESS LOGIC ---
# --- OVERALL PROGRESS LOGIC ---
func _increment_progress() -> void:
	current_cables_connected += 1
	
	# --- NEW: Play the plug sound! ---
	if plug_sound:
		plug_sound.play()
	
	if current_cables_connected >= total_cables_needed:
		if completed_system_unit_texture:
			system_unit_rect.texture = completed_system_unit_texture
		
		mobo_zoom_popup.hide() 
		gpu_zoom_popup.hide()
		complete_button.show()
# --- COMPLETION LOGIC ---
func _on_complete_button_pressed() -> void:
	# --- NEW: Stop the timer and score (e.g., 30s perfect, 90s fail) ---
	GlobalState.stop_scene_timer_and_score("Insert Cables", 30.0, 90.0)

	GlobalState.complete_task("Insert Cables")
	var err = get_tree().change_scene_to_file("res://scenes/COC 1/Assemble Computer Hardware/computer_menu.tscn")
	if err != OK:
		push_error("Failed to load computer_menu scene. Please check the file path!")
