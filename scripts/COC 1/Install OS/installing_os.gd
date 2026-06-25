extends Control

# --- MENU REFERENCES ---
@onready var power_button: TextureButton = $PowerButton
@onready var power_menu: PanelContainer = $PowerMenu
@onready var shutdown_btn: Button = $PowerMenu/VBoxContainer/ShutdownButton
@onready var restart_btn: Button = $PowerMenu/VBoxContainer/RestartButton
@onready var sleep_btn: Button = $PowerMenu/VBoxContainer/SleepButton

# --- SCENE TRANSITION REFERENCES ---
@onready var monitor_background: TextureRect = $Background 
@onready var room_background: TextureRect = $Background2 
@onready var system_unit_view: TextureRect = $SystemUnitView 
@onready var dim_overlay: ColorRect = $DimOverlay

# --- USB & CASE REFERENCES ---
@onready var usb_drive: TextureRect = $SystemUnitView/USB_Drive
@onready var usb_socket: Control = $SystemUnitView/USB_Socket 
@onready var case_power_button: TextureButton = $SystemUnitView/CasePowerButton

# --- BOOT SCREEN REFERENCES ---
@onready var boot_screen: ColorRect = $BootScreen # <--- NEW!
@onready var spam_progress: ProgressBar = $BootScreen/ProgressBar # <--- NEW!

# --- TRACKING VARIABLES ---
var is_usb_inserted: bool = false
var is_booting: bool = false # Tracks if we are in the "mash F6" phase
var f6_presses: int = 0
var required_presses: int = 5 # How many times they must press F6

func _ready() -> void:
	GlobalState.start_scene_timer()
	power_menu.hide()
	dim_overlay.hide()
	boot_screen.hide() # Hide the boot screen at the start!
	
	room_background.hide()
	system_unit_view.hide()
	
	monitor_background.show()
	power_button.show()
	
	power_button.pressed.connect(_on_power_button_pressed)
	shutdown_btn.pressed.connect(_on_shutdown_pressed)
	restart_btn.pressed.connect(_on_fake_option_pressed)
	sleep_btn.pressed.connect(_on_fake_option_pressed)
	
	if case_power_button:
		case_power_button.pressed.connect(_on_case_power_button_pressed)
	
	if usb_socket.has_signal("cable_plugged_in"):
		usb_socket.cable_plugged_in.connect(_on_usb_plugged_in)

# --- MENU LOGIC ---
func _on_power_button_pressed() -> void:
	power_menu.visible = !power_menu.visible

func _on_fake_option_pressed() -> void:
	print("That won't help us install the OS!")
	power_menu.hide()

func _on_shutdown_pressed() -> void:
	print("Shutting down... Initiating perspective shift!")
	power_menu.hide()
	power_button.disabled = true 
	
	dim_overlay.show()
	dim_overlay.color = Color(0, 0, 0, 0) 
	
	var tween = create_tween()
	tween.tween_property(dim_overlay, "color:a", 1.0, 1.5)
	tween.tween_callback(_swap_perspective)
	tween.tween_property(dim_overlay, "color:a", 0.0, 1.5)
	tween.tween_callback(dim_overlay.hide)

func _swap_perspective() -> void:
	monitor_background.hide()
	power_button.hide()
	room_background.show()
	system_unit_view.show()

# --- USB LOGIC ---
func _on_usb_plugged_in() -> void:
	print("Windows Installation USB inserted! Waiting for power on...")
	is_usb_inserted = true

# --- BOOTING UP THE PC ---
func _on_case_power_button_pressed() -> void:
	if is_usb_inserted:
		print("Powering on! Initiating POST sequence...")
		case_power_button.disabled = true 
		_start_boot_sequence()
	else:
		print("Click! ... Hmm, I still need to insert the Windows USB first.")

func _start_boot_sequence() -> void:
	# Show the black boot screen with the text
	boot_screen.show()
	
	# Reset the minigame variables
	is_booting = true
	f6_presses = 0
	spam_progress.value = 0
	spam_progress.max_value = required_presses
	
	# Start a strict 3-second timer!
	get_tree().create_timer(3.0).timeout.connect(_on_boot_timer_ran_out)


# --- LISTENING FOR THE KEYBOARD ---
func _input(event: InputEvent) -> void:
	if is_booting and event is InputEventKey and event.pressed:
		if event.keycode == KEY_F6:
			f6_presses += 1
			spam_progress.value = f6_presses
			print("F6 Pressed! Count: ", f6_presses)
			
			if f6_presses >= required_presses:
				print("SUCCESS! Entering BIOS...")
				is_booting = false # <-- This instantly stops the minigame
				_enter_bios()      # Trigger the loading sequence


func _on_boot_timer_ran_out() -> void:
	# If the timer runs out, and they haven't finished the minigame yet...
	if is_booting:
		print("Too slow! Missed the BIOS window. Booting straight to Windows Setup...")
		is_booting = false
		start_windows_setup()


# --- DESTINATIONS ---
# --- DESTINATIONS ---
func _enter_bios() -> void:
	print("Loading BIOS... please wait 10 seconds.")
	
	# 1. Clean up the screen
	spam_progress.hide() # Hide the progress bar
	
	# (Optional) If you named your text node "Label", you can change the text here!
	var boot_label = boot_screen.get_node_or_null("Label")
	if boot_label:
		boot_label.text = "Entering SETUP..."
	
	# 2. The Magic Pause! Wait exactly 10 seconds.
	await get_tree().create_timer(10.0).timeout
	
	# 3. Finally, change the scene!
	print("10 seconds are up! Changing scene to BIOS Menu!")
	get_tree().change_scene_to_file("res://scenes/COC 1/Installing OS/bios_screen.tscn")

func start_windows_setup() -> void:
	print("Changing scene to Windows Installation!")
	# Transition to your Windows Setup scene!
	# get_tree().change_scene_to_file("res://scenes/windows_installation_screen.tscn")
