extends Control

# --- Main Screens ---
@onready var selection_menu: VBoxContainer = $SetupScreen/VBoxContainer
@onready var screen_1: Control = $SetupScreen/Screen1
@onready var screen_2: Control = $SetupScreen/Screen2

# --- Screen 2 Tabs ---
# Caching the two containers that will be swapped
@onready var computer_list_tab: VBoxContainer = $SetupScreen/Screen2/Panel/Panel/ColorRect/ComputerList
@onready var remote_list_tab: VBoxContainer = $SetupScreen/Screen2/Panel/Panel/ColorRect/VBoxContainer

# --- Screen 2 Specific Elements ---
@onready var computer_name_label: RichTextLabel = $SetupScreen/Screen2/Panel/Panel/ColorRect/ComputerList/RichTextLabel
@onready var rename_dialog: ColorRect = $SetupScreen/Screen2/RenameDialog
@onready var name_input: LineEdit = $SetupScreen/Screen2/RenameDialog/VBoxContainer/NameInput

# --- Screen 2 CheckBoxes ---
@onready var disable_remote_check: CheckBox = $SetupScreen/Screen2/Panel/Panel/ColorRect/VBoxContainer/DisableRemoteCheck
@onready var enable_remote_check: CheckBox = $SetupScreen/Screen2/Panel/Panel/ColorRect/VBoxContainer/EnableRemoteCheck

# --- Screen 3 Specific Elements ---
@onready var screen_3: Control = $SetupScreen/Screen3
@onready var ethernet_context_menu: PopupMenu = $SetupScreen/Screen3/EthernetContextMenu
@onready var properties_dialog: ColorRect = $SetupScreen/Screen3/PropertiesDialog

# Cache the new CheckBoxes
@onready var ipv4_checkbox: CheckBox = $SetupScreen/Screen3/PropertiesDialog/Panel/VBoxContainer/IPv4CheckBox
@onready var ipv6_checkbox: CheckBox = $SetupScreen/Screen3/PropertiesDialog/Panel/VBoxContainer/IPv6CheckBox

# --- Screen 4 Specific Elements ---
@onready var screen_4: Control = $SetupScreen/Screen4
@onready var domain_button: Button = $SetupScreen/Screen4/Panel/VBoxContainer/DomainButton
@onready var private_button: Button = $SetupScreen/Screen4/Panel/VBoxContainer/PrivateButton
@onready var public_button: Button = $SetupScreen/Screen4/Panel/VBoxContainer/PublicNetwork2
@onready var proc_button: Button = $SetupScreen/Screen4/Panel/VBoxContainer/ProcButton

# --- Screen 5 Specific Elements ---
@onready var screen_5: Control = $SetupScreen/Screen5
@onready var time_zone_panel: Panel = $SetupScreen/Screen5/TimeZonePanel
func _ready() -> void:
	# Establish baseline UI state for the main screens
	selection_menu.show()
	screen_1.hide()
	screen_2.hide()
	rename_dialog.hide() 
	
	# Set the default tab for Screen 2
	computer_list_tab.show()
	remote_list_tab.hide()

	# --- NEW: Group the CheckBoxes programmatically ---
	var remote_group = ButtonGroup.new()
	disable_remote_check.button_group = remote_group
	enable_remote_check.button_group = remote_group
	
	# Set the "Don't allow remote connection" as the default pressed option
	# Using set_pressed_no_signal() prevents it from triggering any accidental logic on startup
	disable_remote_check.set_pressed_no_signal(true)
	enable_remote_check.set_pressed_no_signal(false)
	
	screen_3.hide()
	properties_dialog.hide()
	
	# Set initial state for screens 4 and 5
	screen_4.hide()
	screen_5.hide()
	time_zone_panel.hide()
	
	# Initialize Context Menu Items
	# The first parameter is the display text, the second is the internal ID
	ethernet_context_menu.add_item("Disable", 0)
	ethernet_context_menu.add_item("Properties", 1)

func _process(delta: float) -> void:
	pass

# --- Main Selection Menu ---

func _on_server_button_pressed() -> void:
	transition_to_screen_1()

func _on_client_button_pressed() -> void:
	transition_to_screen_1()

func transition_to_screen_1() -> void:
	selection_menu.hide()
	screen_1.show()

# --- Screen 1 ---

func _on_system_properties_button_pressed() -> void:
	screen_1.hide()
	screen_2.show()

func _on_ethernet_button_pressed() -> void:
	# Hide the main menu and show the Network Connections screen
	screen_1.hide()
	screen_3.show()

func _on_firewall_antivirus_button_pressed() -> void:
	screen_1.hide()
	screen_4.show()

func _on_change_time_button_pressed() -> void:
	screen_1.hide()
	screen_5.show()

# --- Screen 2 (System Properties Tabs) ---

func _on_computer_button_pressed() -> void:
	# Show the Computer Name content, hide the Remote content
	remote_list_tab.hide()
	computer_list_tab.show()

func _on_remote_button_pressed() -> void:
	# Show the Remote content, hide the Computer Name content
	computer_list_tab.hide()
	remote_list_tab.show()

func _on_change_button_pressed() -> void:
	# Hide the computer list tab and show the pop-up dialog
	computer_list_tab.hide()
	rename_dialog.show()

# --- Rename Dialog (Pop-up) ---

func _on_apply_button_pressed() -> void:
	var new_computer_name = name_input.text.strip_edges()
	
	if new_computer_name != "":
		# This line effectively "saves" the name to the UI label
		computer_name_label.text = new_computer_name
		print("Computer Name successfully updated to: ", new_computer_name)
	
	# Clear input, hide pop-up, and bring the computer list back
	name_input.clear()
	rename_dialog.hide()
	computer_list_tab.show()

func _on_cancel_button_pressed() -> void:
	# Clear input, hide pop-up, and bring the computer list back without saving changes
	name_input.clear()
	rename_dialog.hide()
	computer_list_tab.show()


# --- Screen 2 Main Window Buttons ---

func _on_ok_btn_pressed() -> void:
	# The CheckBox states and the new Computer Name are natively held in the UI nodes.
	# By simply hiding Screen 2, those states are "remembered" for the next time it opens.
	screen_2.hide()
	screen_1.show()

func _on_cancel_btn_pressed() -> void:
	# In a fully comprehensive app, Cancel might revert variables to a previous state.
	# For the current visual scope of this simulation, simply returning to Screen 1 is sufficient.
	screen_2.hide()
	screen_1.show()

# --- Screen 3 (Network Connections) ---

func _on_ethernet_btn_gui_input(event: InputEvent) -> void:
	# Check if the input is a mouse button, if it is pressed down, and if it is the Right Click (Button 2)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# Move the popup menu to exactly where the mouse cursor is, then show it
		ethernet_context_menu.position = get_global_mouse_position()
		ethernet_context_menu.popup()

func _on_ethernet_context_menu_id_pressed(id: int) -> void:
	# Handle the logic based on the ID we assigned in the _ready() function
	if id == 0:
		print("Network Disabled")
		# Add future logic here for changing the network state
	elif id == 1:
		# Properties was clicked, show the dialog box
		properties_dialog.show()
# --- Properties Dialog Pop-up ---

func _on_close_properties_button_pressed() -> void:
	properties_dialog.hide()

func _on_i_pv_6_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		print("IPv6 is now ENABLED")
	else:
		print("IPv6 is now DISABLED")

func _on_i_pv_4_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		print("IPv4 is now ENABLED")
		# Add logic here if checking the box should unlock other UI elements
	else:
		print("IPv4 is now DISABLED")

# --- Screen 3 Main Window Buttons ---

func _on_screen_3_ok_btn_pressed() -> void:
	# Close Network Connections and return to the main System Properties menu
	screen_3.hide()
	screen_1.show()

func _on_screen_3_cancel_btn_pressed() -> void:
	# Close Network Connections and return to the main menu without saving changes
	screen_3.hide()
	screen_1.show()


# --- Screen 4 (Firewall & Antivirus) ---

func _on_domain_button_pressed() -> void:
	domain_button.text = "Turn off"

func _on_private_button_pressed() -> void:
	private_button.text = "Turn off"

func _on_public_network_2_pressed() -> void:
	public_button.text = "Turn off"

func _on_proc_button_pressed() -> void:
	proc_button.text = "Turn off"

func _on_screen_4_cancel_btn_pressed() -> void:
	screen_4.hide()
	screen_1.show()

# --- Screen 5 (Change Time) ---

func _on_time_zone_btn_pressed() -> void:
	time_zone_panel.show()

func _on_screen_5_cancel_btn_pressed() -> void:
	screen_5.hide()
	screen_1.show()

# --- New Time Zone Panel Buttons ---

func _on_back_button_pressed() -> void:
	time_zone_panel.hide()

func _on_beijing_button_pressed() -> void:
	print("Time zone updated to: (UTC+8) Beijing")
	time_zone_panel.hide()

func _on_tomsk_button_pressed() -> void:
	print("Time zone updated to: (UTC+7) Tomsk")
	time_zone_panel.hide()

func _on_hovd_button_pressed() -> void:
	print("Time zone updated to: (UTC+7) Hovd")
	time_zone_panel.hide()

func _on_bangkok_button_pressed() -> void:
	print("Time zone updated to: (UTC+7) Bangkok")
	time_zone_panel.hide()

func _on_kuala_lumpur_button_pressed() -> void:
	print("Time zone updated to: (UTC+8) Kuala Lumpur")
	time_zone_panel.hide()
