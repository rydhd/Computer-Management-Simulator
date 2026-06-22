extends Control

@onready var prompt_label = $PromptLabel
@onready var screw_container = $ScrewContainer
@onready var draggable_motherboard = $DraggableMotherboard
@onready var complete_button = $CompleteButton

# --- Audio and UI Nodes ---
@onready var snap_sound = $SnapSound 
@onready var drill_sound = $DrillSound 
@onready var progress_bar = $ProgressBar 

# --- Overlay References ---
@onready var screw_counter_overlay = $ScrewCounterOverlay
@onready var screw_count_label = $ScrewCounterOverlay/MarginContainer/ScrewCountLabel

var screws_fastened: int = 0
var total_screws: int = 0

var active_screw: TextureButton = null
var current_hold_time: float = 0.0
var required_hold_time: float = 1.5 

func _ready() -> void:
	# --- NEW: Show starting instructions ---
	if prompt_label:
		prompt_label.text = "Drag the motherboard into the system unit."
		prompt_label.show()
	
	screw_container.hide()
	
	if progress_bar:
		progress_bar.hide() 
		
	if screw_counter_overlay:
		screw_counter_overlay.hide()
	
	if complete_button:
		complete_button.hide()
		complete_button.pressed.connect(_on_complete_button_pressed)
	
	total_screws = screw_container.get_child_count()
	
	for screw in screw_container.get_children():
		if screw is TextureButton:
			screw.button_down.connect(_on_screw_button_down.bind(screw))
			screw.button_up.connect(_on_screw_button_up.bind(screw))
			screw.mouse_exited.connect(_on_screw_button_up.bind(screw))
		
	if draggable_motherboard:
		draggable_motherboard.installed.connect(_on_motherboard_installed)

func _process(delta: float) -> void:
	if active_screw != null:
		current_hold_time += delta
		
		if progress_bar:
			progress_bar.value = (current_hold_time / required_hold_time) * 100
		
		if current_hold_time >= required_hold_time:
			_finish_fastening_screw(active_screw)

func _on_motherboard_installed() -> void:
	# --- NEW: Update instructions for the next phase ---
	if prompt_label:
		prompt_label.text = "Click and hold the screws to secure it!"
	
	screw_container.show()
	
	if progress_bar:
		progress_bar.show()
		progress_bar.value = 0
		
	if screw_counter_overlay and screw_count_label:
		screw_counter_overlay.show()
		screw_count_label.text = "Screws Fastened: 0 / " + str(total_screws)
	
	if snap_sound:
		snap_sound.play()

func _on_screw_button_down(screw_button: TextureButton) -> void:
	active_screw = screw_button
	current_hold_time = 0.0
	
	if progress_bar:
		progress_bar.value = 0
	
	if drill_sound:
		drill_sound.play()

func _on_screw_button_up(screw_button: TextureButton) -> void:
	if active_screw == screw_button:
		active_screw = null
		current_hold_time = 0.0
		
		if progress_bar:
			progress_bar.value = 0
		
		if drill_sound:
			drill_sound.stop()

func _finish_fastening_screw(screw_button: TextureButton) -> void:
	active_screw = null
	current_hold_time = 0.0
	
	if progress_bar:
		progress_bar.value = 0
	
	if drill_sound:
		drill_sound.stop()
	
	screw_button.disabled = true
	screw_button.hide() 
	
	screws_fastened += 1
	
	if screw_count_label:
		screw_count_label.text = "Screws Fastened: " + str(screws_fastened) + " / " + str(total_screws)
	
	if screws_fastened >= total_screws:
		if progress_bar:
			progress_bar.hide()
			
		if screw_counter_overlay:
			screw_counter_overlay.hide()
			
		prompt_label.text = "Motherboard successfully secured!"
		if complete_button:
			complete_button.show()

func _on_complete_button_pressed() -> void:
	GlobalState.complete_task("Fix PC: System Unit Installation")
	get_tree().change_scene_to_file("res://scenes/COC 1/Assemble Computer Hardware/computer_menu.tscn")
