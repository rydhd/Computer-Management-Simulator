extends Control

# --- REFERENCES ---
@onready var cable_tray: Control = $CableTray
@onready var psu_drop_zone: Control = $SystemUnit/PSUDropZone
@onready var mobo_button: TextureButton = $SystemUnit/MoboButton
@onready var mobo_zoom_popup: ColorRect = $MoboZoomPopup
@onready var close_zoom_button: TextureButton = $MoboZoomPopup/ZoomedMoboVisual/CloseButton

# --- NEW: Reference to the Complete Button ---
@onready var complete_button: Button = $CompleteButton

# --- NEW: Tracking Variables ---
# Set this to however many cables you have in your scene! (e.g., 2 or 3)
@export var total_cables_needed: int = 2 
var current_cables_connected: int = 0


func _ready() -> void:
	cable_tray.hide()
	mobo_zoom_popup.hide()
	complete_button.hide()
	
	# Connect existing signals
	psu_drop_zone.psu_installed.connect(_on_psu_installed)
	mobo_button.pressed.connect(_on_mobo_clicked)
	close_zoom_button.pressed.connect(_on_close_zoom_clicked)
	
	
	var zoomed_mobo = $MoboZoomPopup/ZoomedMoboVisual
	for child in zoomed_mobo.get_children():
		if child.has_signal("cable_plugged_in"):
			child.cable_plugged_in.connect(_on_any_cable_plugged_in)
func _on_psu_installed() -> void:
	cable_tray.show()

func _on_mobo_clicked() -> void:
	mobo_zoom_popup.show()

func _on_close_zoom_clicked() -> void:
	mobo_zoom_popup.hide()


# --- NEW: The Tracking Logic ---
func _on_any_cable_plugged_in() -> void:
	# Add 1 to our tracker
	current_cables_connected += 1
	print("Progress: ", current_cables_connected, " / ", total_cables_needed)
	
	# Check if we hit the target!
	if current_cables_connected >= total_cables_needed:
		print("All cables connected! Showing the Complete button.")
		
		# Optional: Auto-close the zoom popup when finished so they see the button!
		# mobo_zoom_popup.hide() 
		
		complete_button.show()


# --- NEW: The Completion Logic ---
func _on_complete_button_pressed() -> void:
	print("Cables inserted! Returning to Computer Menu...")
	
	# 1. Mark this specific sub-task as complete in the Global State.
	# IMPORTANT: Change "Insert Cables" to match the EXACT text used in your computer_menu list!
	GlobalState.complete_task("Insert Cables")
	
	# 2. Return to the Computer Menu scene
	# (Right-click computer_menu.tscn in your FileSystem and select "Copy Path" if this path is wrong)
	var err = get_tree().change_scene_to_file("res://scenes/COC 1/Assemble Computer Hardware/computer_menu.tscn")
	
	if err != OK:
		push_error("Failed to load computer_menu scene. Please check the file path!")
