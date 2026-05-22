extends Control

# --- SCREEN REFERENCES ---
@onready var screen_1_language: Control = $SetupWindow/Screen1_Language
@onready var screen_2_install: Control = $SetupWindow/Screen2_Install
@onready var screen_license: Control = $SetupWindow/Screen_License       
@onready var screen_install_type: Control = $SetupWindow/Screen_InstallType
@onready var screen_3_drive: Control = $SetupWindow/Screen3_Drive
@onready var screen_4_progress: Control = $SetupWindow/Screen4_Progress

# --- NEW: RESTART SCREEN REFERENCES ---
@onready var setup_window: ColorRect = $SetupWindow
@onready var screen_restart: Control = $SetupWindow/Screen_Restart
@onready var restart_label: Label = $SetupWindow/Screen_Restart/VBoxContainer/RestartLabel
@onready var restart_logo: TextureRect = $SetupWindow/Screen_Restart/VBoxContainer/TextureRect

# --- BUTTON REFERENCES ---
@onready var btn_next_1: Button = $SetupWindow/Screen1_Language/NextButton
@onready var btn_install: Button = $SetupWindow/Screen2_Install/InstallButton
@onready var btn_next_license: Button = $SetupWindow/Screen_License/LicenseNextButton  
@onready var chk_accept: CheckBox = $SetupWindow/Screen_License/AcceptCheckBox         
@onready var btn_type_upgrade: Button = $SetupWindow/Screen_InstallType/VBoxContainer/UpgradeButton 
@onready var btn_type_custom: Button = $SetupWindow/Screen_InstallType/VBoxContainer/CustomButton   
@onready var btn_next_drive: Button = $SetupWindow/Screen3_Drive/VBoxContainer/FooterBox/DriveNextButton

# --- DROPDOWN REFERENCES ---
@onready var lang_dropdown: OptionButton = $SetupWindow/Screen1_Language/VBoxContainer/HBoxContainer/LanguageDropdown
@onready var time_dropdown: OptionButton = $SetupWindow/Screen1_Language/VBoxContainer/HBoxContainer2/TimeDropdown
@onready var keyboard_dropdown: OptionButton = $SetupWindow/Screen1_Language/VBoxContainer/HBoxContainer3/KeyboardDropdown

# --- DRIVE SCREEN REFERENCES ---
@onready var drive_tree: Tree = $SetupWindow/Screen3_Drive/VBoxContainer/DriveList

# --- PROGRESS REFERENCES ---
@onready var progress_bar: ProgressBar = $SetupWindow/Screen4_Progress/ProgressBar
@onready var status_label: Label = $SetupWindow/Screen4_Progress/StatusLabel

func _ready() -> void:
	# 1. Hide all screens EXCEPT the first one
	screen_2_install.hide()
	screen_license.hide() 
	screen_install_type.hide()
	screen_3_drive.hide()
	screen_4_progress.hide()
	if screen_restart: screen_restart.hide() # Make sure restart overlay is hidden

	# 2. Wire up buttons via code
	if not btn_next_1.pressed.is_connected(_on_next_1_pressed):
		btn_next_1.pressed.connect(_on_next_1_pressed)
	if not btn_install.pressed.is_connected(_on_install_pressed):
		btn_install.pressed.connect(_on_install_pressed)
	if not btn_next_drive.pressed.is_connected(_on_next_drive_pressed):
		btn_next_drive.pressed.connect(_on_next_drive_pressed)
		
	# Connect the new License screen nodes
	if not btn_next_license.pressed.is_connected(_on_license_next_pressed):
		btn_next_license.pressed.connect(_on_license_next_pressed)
	if not chk_accept.toggled.is_connected(_on_accept_toggled):
		chk_accept.toggled.connect(_on_accept_toggled)

	# Connect the Install Type nodes
	if not btn_type_upgrade.pressed.is_connected(_on_upgrade_pressed):
		btn_type_upgrade.pressed.connect(_on_upgrade_pressed)
	if not btn_type_custom.pressed.is_connected(_on_custom_pressed):
		btn_type_custom.pressed.connect(_on_custom_pressed)

	# Connect the Drive Tree
	if drive_tree and not drive_tree.item_selected.is_connected(_on_drive_selected):
		drive_tree.item_selected.connect(_on_drive_selected)

	# 3. Connect dropdown signals
	if not lang_dropdown.item_selected.is_connected(_on_language_selected):
		lang_dropdown.item_selected.connect(_on_language_selected)
	if not time_dropdown.item_selected.is_connected(_on_time_selected):
		time_dropdown.item_selected.connect(_on_time_selected)
	if not keyboard_dropdown.item_selected.is_connected(_on_keyboard_selected):
		keyboard_dropdown.item_selected.connect(_on_keyboard_selected)

	# 4. Set Initial States
	btn_next_license.disabled = true
	_populate_dropdowns()
	_populate_drives() 

func _populate_dropdowns() -> void:
	lang_dropdown.clear()
	lang_dropdown.add_item("English (United States)")
	lang_dropdown.add_item("English (United Kingdom)")

	time_dropdown.clear()
	time_dropdown.add_item("English (United States)")

	keyboard_dropdown.clear()
	keyboard_dropdown.add_item("US")
	keyboard_dropdown.add_item("US - International")
	keyboard_dropdown.add_item("United Kingdom")


# --- WIZARD NAVIGATION ---
func _on_next_1_pressed() -> void:
	screen_1_language.hide()
	screen_2_install.show()

func _on_install_pressed() -> void:
	screen_2_install.hide()
	screen_license.show()

# --- LICENSE SCREEN LOGIC ---
func _on_accept_toggled(toggled_on: bool) -> void:
	btn_next_license.disabled = not toggled_on

func _on_license_next_pressed() -> void:
	screen_license.hide()
	screen_install_type.show() 

# --- INSTALL TYPE SCREEN LOGIC ---
func _on_upgrade_pressed() -> void:
	print("Player chose Upgrade Install!")
	screen_install_type.hide()
	screen_3_drive.show()

func _on_custom_pressed() -> void:
	print("Player chose Custom (Advanced) Install!")
	screen_install_type.hide()
	screen_3_drive.show()

# --- DRIVE PARTITION LOGIC ---
func _populate_drives() -> void:
	if not drive_tree: 
		printerr("ERROR: DriveList node not found! Check the drive_tree @onready path.")
		return
	
	drive_tree.clear()
	drive_tree.columns = 4
	drive_tree.set_column_title(0, "Name")
	drive_tree.set_column_title(1, "Total Size")
	drive_tree.set_column_title(2, "Free Space")
	drive_tree.set_column_title(3, "Type")
	
	drive_tree.column_titles_visible = true
	drive_tree.hide_root = true
	drive_tree.select_mode = Tree.SELECT_ROW 
	
	var root = drive_tree.create_item()
	
	_create_drive_item(root, "Drive 0 Partition 1: System", "100.0 MB", "95.0 MB", "System")
	_create_drive_item(root, "Drive 0 Partition 2", "450.0 GB", "450.0 GB", "Primary")
	_create_drive_item(root, "Drive 0 Partition 3: Recovery", "500.0 MB", "480.0 MB", "Recovery")
	
	if btn_next_drive:
		btn_next_drive.disabled = true 

func _create_drive_item(parent: TreeItem, drive_name: String, total: String, free: String, type: String) -> void:
	var item = drive_tree.create_item(parent)
	item.set_text(0, drive_name)
	item.set_text(1, total)
	item.set_text(2, free)
	item.set_text(3, type)

func _on_drive_selected() -> void:
	if btn_next_drive:
		btn_next_drive.disabled = false

# --- THE FAKE INSTALLATION SEQUENCE ---
func _on_next_drive_pressed() -> void:
	screen_3_drive.hide()
	screen_4_progress.show()
	_start_installation()

func _start_installation() -> void:
	progress_bar.value = 0
	status_label.text = "Copying Windows files..."

	var tween = create_tween()
	
	tween.tween_property(progress_bar, "value", 20.0, 2.0)
	tween.tween_callback(func(): status_label.text = "Getting files ready for installation (This may take a while)...")
	
	tween.tween_property(progress_bar, "value", 80.0, 4.0)
	tween.tween_callback(func(): status_label.text = "Installing updates and finishing up...")
	
	tween.tween_property(progress_bar, "value", 100.0, 2.0)
	tween.tween_callback(_on_installation_complete)

func _on_installation_complete() -> void:
	status_label.text = "Windows needs to restart to continue."
	await get_tree().create_timer(3.0).timeout
	print("OS successfully installed! Simulating restart...")
	
	# Transition to the Restart Screen
	screen_4_progress.hide()
	screen_restart.show()
	_simulate_reboot()

func _simulate_reboot() -> void:
	# 1. Shows "Restarting..."
	restart_label.text = "Restarting..."
	restart_logo.show()
	await get_tree().create_timer(2.0).timeout

	# 2. Simulate PC turning off (black screen)
	restart_label.text = ""
	restart_logo.hide()
	await get_tree().create_timer(1.5).timeout

	# 3. Simulate booting up again
	restart_logo.show()
	restart_label.text = "Getting devices ready..."
	await get_tree().create_timer(2.5).timeout

	restart_label.text = "Just a moment..."
	await get_tree().create_timer(2.0).timeout

	# 4. Transition to Part 2!
	# NOTE: Please verify this path matches exactly where your Part 2 scene is located!
	get_tree().change_scene_to_file("res://scenes/COC 1/Installing OS/windows_installation_part_2.tscn")
	
# --- DROPDOWN CALLBACKS ---
func _on_language_selected(index: int) -> void:
	print("Selected Language Index: ", index)

func _on_time_selected(index: int) -> void:
	print("Selected Time/Currency Index: ", index)

func _on_keyboard_selected(index: int) -> void:
	print("Selected Keyboard Index: ", index)
