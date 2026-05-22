extends Control

# --- SCREEN REFERENCES ---
# Updated to use $PCWindow to match your actual scene tree!
@onready var screen_1_region: Control = $PCWindow/Screen1_Region
@onready var screen_2_network: Control = $PCWindow/Screen2_Network
@onready var screen_3_account: Control = $PCWindow/Screen3_Account
@onready var screen_4_internet: Control = $PCWindow/Screen4_Internet 
@onready var screen_5_final: Control = $PCWindow/Screen5_Final       
@onready var screen_6_done: Control = $PCWindow/Screen6_Done # <-- FINISHING SCREEN

# --- BUTTON REFERENCES ---
@onready var btn_next_region: Button = $PCWindow/Screen1_Region/NextButton
@onready var btn_next_network: Button = $PCWindow/Screen2_Network/NextButton
@onready var btn_next_account: Button = $PCWindow/Screen3_Account/HBoxContainer/NextButton
@onready var btn_no_internet: Button = $PCWindow/Screen4_Internet/NoInternetButton 
@onready var btn_next_final: Button = $PCWindow/Screen5_Final/NextButton

# --- FINISH SCREEN REFERENCES ---
@onready var finish_status_label: RichTextLabel = $PCWindow/Screen6_Done/StatusLabel

func _ready() -> void:
	# --- DEBUGGING CHECK ---
	if screen_2_network == null:
		printerr("ERROR: Could not find Screen2! Make sure it is named EXACTLY 'Screen2_Network' and is a child of PCWindow.")
	if screen_3_account == null:
		printerr("ERROR: Could not find Screen3! Make sure it is named EXACTLY 'Screen3_Account'.")
	if screen_4_internet == null:
		printerr("ERROR: Could not find Screen4! Make sure it is named EXACTLY 'Screen4_Internet'.")
	if screen_5_final == null:
		printerr("ERROR: Could not find Screen5! Make sure it is named EXACTLY 'Screen5_Final'.")
	if screen_6_done == null:
		printerr("ERROR: Could not find Screen6! Make sure it is named EXACTLY 'Screen6_Done'.")

	# 1. Explicitly show the first screen and hide all the others
	if screen_1_region: screen_1_region.show()
	if screen_2_network: screen_2_network.hide()
	if screen_3_account: screen_3_account.hide()
	if screen_4_internet: screen_4_internet.hide()
	if screen_5_final: screen_5_final.hide()
	if screen_6_done: screen_6_done.hide()

	# 2. Wire up buttons safely via code
	if btn_next_region and not btn_next_region.pressed.is_connected(_on_region_next_pressed):
		btn_next_region.pressed.connect(_on_region_next_pressed)
		
	if btn_next_network and not btn_next_network.pressed.is_connected(_on_network_next_pressed):
		btn_next_network.pressed.connect(_on_network_next_pressed)
		
	if btn_next_account and not btn_next_account.pressed.is_connected(_on_account_next_pressed):
		btn_next_account.pressed.connect(_on_account_next_pressed)
		
	if btn_no_internet and not btn_no_internet.pressed.is_connected(_on_no_internet_pressed):
		btn_no_internet.pressed.connect(_on_no_internet_pressed)
		
	if btn_next_final and not btn_next_final.pressed.is_connected(_on_final_next_pressed):
		btn_next_final.pressed.connect(_on_final_next_pressed)

# --- SCREEN TRANSITIONS ---
func _on_region_next_pressed() -> void:
	screen_1_region.hide()
	screen_2_network.show()

func _on_network_next_pressed() -> void:
	screen_2_network.hide()
	screen_3_account.show()

func _on_account_next_pressed() -> void:
	screen_3_account.hide()
	screen_4_internet.show()

func _on_no_internet_pressed() -> void:
	print("Player skipped internet setup! Proceeding to limited setup...")
	screen_4_internet.hide()
	screen_5_final.show()

# --- FINISHING LOGIC ---
func _on_final_next_pressed() -> void:
	screen_5_final.hide()
	screen_6_done.show()
	_start_finishing_sequence()

func _start_finishing_sequence() -> void:
	if finish_status_label == null: return
	
	finish_status_label.text = "Hi."
	
	# Using Godot 4's Tween system to create a text animation sequence
	var tween = create_tween()
	
	tween.tween_interval(2.0)
	tween.tween_callback(func(): finish_status_label.text = "We're getting everything ready for you.")
	
	tween.tween_interval(3.0)
	tween.tween_callback(func(): finish_status_label.text = "This might take several minutes.")
	
	tween.tween_interval(3.0)
	tween.tween_callback(func(): finish_status_label.text = "Almost there...")
	
	tween.tween_interval(2.0)
	tween.tween_callback(_on_setup_complete)

func _on_setup_complete() -> void:
	if finish_status_label:
		finish_status_label.text = "Installing OS is finished!"
		
	print("OOBE Setup Complete! Transitioning to Shop...")
	
	# 1. Check off the task in the GlobalState so the Taskboard updates
	# Note: Now perfectly matches the exact string in your GlobalState task list!
	GlobalState.complete_task("Installing Operating System") 
	
	# 2. Wait 1.5 seconds so the player can actually read the "finished!" text
	await get_tree().create_timer(1.5).timeout
	
	# 3. Go back to the shop scene to arrange cables!
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
