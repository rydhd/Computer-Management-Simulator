extends Control

# --- UI Node References ---
@onready var main_menu: Control = $MainMenu
@onready var gameplay_panel: Control = $GameplayPanel
@onready var wiring_slots: HBoxContainer = $GameplayPanel/WiringSlots
@onready var feedback_label: RichTextLabel = $GameplayPanel/FeedbackLabel
@onready var target_standard_label: Label = $GameplayPanel/TargetStandardLabel # Add this line
# --- Wiring Standards Setup ---
enum WiringStandard { T568A, T568B }
@onready var wire_inventory: HBoxContainer = $GameplayPanel/WireInventory
# Set this based on whatever standard the player is currently tasked with
var current_target_standard: WiringStandard = WiringStandard.T568B

# Define the correct color sequences for validation using the exact file names
const T568A_COLORS: Array[String] = [
	"GreenWhite", "Green", "OrangeWhite", "Blue", "BlueWhite", "Orange", "BrownWhite", "Brown"
]

const T568B_COLORS: Array[String] = [
	"OrangeWhite", "Orange", "GreenWhite", "Blue", "BlueWhite", "Green", "BrownWhite", "Brown"
]

# Track the player's real-time arrangement (8 empty slots)
var player_arrangement: Array[String] = ["", "", "", "", "", "", "", ""]

func _ready() -> void:
	# Keep existing visibility toggles
	main_menu.show()
	gameplay_panel.hide()
	
	# Dynamically connect the drop signals from all 8 slots
	for slot in wiring_slots.get_children():
		if slot.has_signal("wire_dropped"):
			slot.connect("wire_dropped", Callable(self, "place_wire"))

func _on_start_button_pressed() -> void:
	# Ensure the board is clear before starting
	reset_wires()
	
	# Shuffle the required wiring standard
	randomize_standard()
	
	# Hide the menu and show the gameplay background and RJ45 TextureRect
	main_menu.hide()
	gameplay_panel.show()
	
	# --- NEW: Start the timer now that the board is visible! ---
	GlobalState.start_scene_timer()
func _on_back_button_pressed() -> void:
	# Reset back to the main menu
	gameplay_panel.hide()
	main_menu.show()

# --- Gameplay Functions ---

# Call this function whenever a player successfully places a wire into a slot
func place_wire(slot_index: int, wire_color: String) -> void:
	player_arrangement[slot_index] = wire_color
	
	# Check if all 8 slots are filled before validating
	if not "" in player_arrangement:
		validate_wiring()
# Resets the board so the player can try again
# Resets the board so the player can try again
func reset_wires() -> void:
	# 1. Clear the data array back to 8 empty strings
	player_arrangement = ["", "", "", "", "", "", "", ""]
	
	# 2. Clear the feedback text
	feedback_label.text = ""
	
	# 3. Loop through all the UI slots to remove textures and reset color
	for slot in wiring_slots.get_children():
		slot.texture = null
		slot.modulate = Color(1, 1, 1, 1) 
		
	# 4. NEW: Reset the flags and opacity of the inventory wires so the student can retry
	for wire in wire_inventory.get_children():
		if "is_placed" in wire:
			wire.is_placed = false
			wire.modulate.a = 1.0 # Restore full opacity
func validate_wiring() -> void:
	var target_sequence: Array[String] = T568A_COLORS if current_target_standard == WiringStandard.T568A else T568B_COLORS
	var is_correct: bool = true
	var wrong_positions: Array[int] = [] 
	
	for i in range(player_arrangement.size()):
		if player_arrangement[i] != target_sequence[i]:
			is_correct = false
			wrong_positions.append(i)
			
	if is_correct:
		# Success state
		feedback_label.text = "Correct Alignment! Trigger RJ45 insertion sequence."
		feedback_label.add_theme_color_override("font_color", Color(0, 1, 0)) 
		
		# --- NEW: Stop the timer and calculate the score ---
		# Example: 25 seconds for a perfect score, 90 seconds for a 0 score.
		GlobalState.stop_scene_timer_and_score("Arrange Cables", 25.0, 90.0)
		
		# Update GlobalState and transition back to Shop2d
		GlobalState.complete_task("Arrange Cables")
		GlobalState.customer_job_finished = true
		
		# Wait 2.5 seconds so the player can read the success message
		await get_tree().create_timer(2.5).timeout
		
		# Transition back to the shop. 
		get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
		
	else:
		# Failure state
		var error_message: String = "Incorrect alignment at position(s): "
		
		# Loop through all the recorded mistakes
		for index in wrong_positions:
			# Add 1 to the index so it displays 1-8 instead of 0-7 for the player
			error_message += str(index + 1) + " "
			
			# Tint the specific incorrect slot red
			var incorrect_slot = wiring_slots.get_child(index)
			incorrect_slot.modulate = Color(1, 0, 0, 1) # Red color
		
		# Update the label and tint the text red
		feedback_label.text = error_message + "\nTry again."
		feedback_label.add_theme_color_override("font_color", Color(1, 0, 0))
		
		# Pause for 2.0 seconds so the player can process their mistakes
		await get_tree().create_timer(2.0).timeout
		
		# Clear the board
		reset_wires()
		
# Randomly selects between T568A and T568B and updates the UI
func randomize_standard() -> void:
	# Ensure the random number generator creates a new seed every time
	randomize() 
	
	# randi() % 2 will return either 0 (T568A) or 1 (T568B)
	current_target_standard = randi() % 2 as WiringStandard
	
	# Update the label so the player knows the objective
	if current_target_standard == WiringStandard.T568A:
		target_standard_label.text = "Target Standard: T-568A"
	else:
		target_standard_label.text = "Target Standard: T-568B"
