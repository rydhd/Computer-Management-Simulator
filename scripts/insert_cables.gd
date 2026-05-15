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
	
	# Hide the complete button at the start!
	complete_button.hide()
	
	# Connect existing signals
	psu_drop_zone.psu_installed.connect(_on_psu_installed)
	mobo_button.pressed.connect(_on_mobo_clicked)
	close_zoom_button.pressed.connect(_on_close_zoom_clicked)
	
	# --- NEW: Connect all sockets on the zoomed motherboard to our tracking function ---
	# We loop through all the children of ZoomedMoboVisual to find our sockets automatically!
	var zoomed_mobo = $MoboZoomPopup/ZoomedMoboVisual
	for child in zoomed_mobo.get_children():
		# Check if the child has our custom signal (meaning it's a mobo socket!)
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


func _on_complete_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/COC 1/Assemble Computer Hardware/computer_menu.tscn")
