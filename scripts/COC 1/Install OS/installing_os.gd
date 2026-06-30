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
@onready var boot_screen: ColorRect = $BootScreen
@onready var spam_progress: ProgressBar = $BootScreen/ProgressBar 

# --- NEW: INSTRUCTION PROMPT REFERENCE ---
@onready var instruction_label: Label = $InstructionLabel

# --- TRACKING VARIABLES ---
var is_usb_inserted: bool = false
var is_booting: bool = false
var f6_presses: int = 0
var required_presses: int = 5 

func _ready() -> void:
	GlobalState.start_scene_timer()
	power_menu.hide()
	dim_overlay.hide()
	boot_screen.hide() 
	room_background.hide()
	system_unit_view.hide()
	
	monitor_background.show()
	power_button.show()
	
	# --- NEW: Set initial instruction ---
	if instruction_label:
		instruction_label.text = "Click the Windows icon and Shutdown the computer."
		instruction_label.show()
	
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
	power_menu.hide()
	power_button.disabled = true 
	
	# Hide the instruction temporarily during the fade
	if instruction_label:
		instruction_label.hide()
	
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
	
	# --- NEW: Update instruction for USB ---
	if instruction_label:
		instruction_label.text = "Drag the Windows OS flash drive into the USB port."
		instruction_label.show()

# --- USB LOGIC ---
func _on_usb_plugged_in() -> void:
	is_usb_inserted = true
	
	# --- NEW: Update instruction for Power Button ---
	if instruction_label:
		instruction_label.text = "Press the power button on the case to turn it on."

# --- BOOTING UP THE PC ---
func _on_case_power_button_pressed() -> void:
	if is_usb_inserted:
		case_power_button.disabled = true 
		_start_boot_sequence()

func _start_boot_sequence() -> void:
	boot_screen.show()
	
	# --- NEW: Update instruction for BIOS minigame ---
	if instruction_label:
		instruction_label.text = "Press F6 repeatedly to enter the BIOS!"
	
	is_booting = true
	f6_presses = 0
	spam_progress.value = 0
	spam_progress.max_value = required_presses
	
	get_tree().create_timer(100.0).timeout.connect(_on_boot_timer_ran_out)


# --- LISTENING FOR THE KEYBOARD ---
func _input(event: InputEvent) -> void:
	if is_booting and event is InputEventKey and event.pressed:
		if event.keycode == KEY_F6:
			f6_presses += 1
			spam_progress.value = f6_presses
			
			if f6_presses >= required_presses:
				is_booting = false 
				_enter_bios()      


func _on_boot_timer_ran_out() -> void:
	if is_booting:
		is_booting = false
		start_windows_setup()


# --- DESTINATIONS ---
func _enter_bios() -> void:
	spam_progress.hide() 
	
	# Hide top instruction label since the boot screen takes over
	if instruction_label:
		instruction_label.hide()
		
	var boot_label = boot_screen.get_node_or_null("Label")
	if boot_label:
		boot_label.text = "Entering SETUP..."
	
	await get_tree().create_timer(10.0).timeout
	get_tree().change_scene_to_file("res://scenes/COC 1/Installing OS/bios_screen.tscn")

func start_windows_setup() -> void:
	pass
