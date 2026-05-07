extends Control

const TASK_BRIEFING_SCENE = preload("res://scenes/task_briefing_menu.tscn")


@onready var margin_container: MarginContainer = $MarginContainer
@onready var task_list: VBoxContainer = $MarginContainer/TaskList
@onready var close_button: Button = $CloseButton

# --- INSPECTOR VARIABLES ---
@export_group("Task Text Styling")
@export var text_font_size: int = 24
@export var normal_text_color: Color = Color(0.1, 0.1, 0.1)
@export var hover_text_color: Color = Color(0.2, 0.4, 0.8)
@export var disabled_text_color: Color = Color(0.4, 0.4, 0.4, 0.6)

@export_group("Task Text Layout & Position")
@export var text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
@export var vertical_spacing_between_tasks: int = 10
@export var list_padding_left: int = 30  # Pushes the text to the right
@export var list_padding_top: int = 50   # Pushes the text down from the top
# ---------------------------

# Use an Array of Dictionaries so the tasks stay in a strict, ordered sequence.
var tasks: Array = [] # Start empty!

func _ready() -> void:
	visible = false
	close_button.pressed.connect(hide_board)
	
	# Apply our layout positioning to the Containers!
	margin_container.add_theme_constant_override("margin_left", list_padding_left)
	margin_container.add_theme_constant_override("margin_top", list_padding_top)
	task_list.add_theme_constant_override("separation", vertical_spacing_between_tasks)
	
	# --- NEW CODE: Connect to the EventBus ---
	EventBus.issue_clipped_to_board.connect(_on_issue_clipped)
	
	_populate_tasks()
	
# --- NEW FUNCTION ---
# This runs automatically when the "Clip" button in IssuePopupUI is clicked
# Inside taskboard_overlay.gd

# Inside taskboard_overlay.gd

func _on_issue_clipped(issue_id: String) -> void:
	# Match the string ID sent by the popup to create the correct tasks!
	match issue_id:
		# --- THE GELO COMBO ---
		"task_001_gelo":
			# Append all 3 tasks in the exact order they need to be completed!
			tasks.append({"name": "Assemble Computer Hardware", "scene": "res://scenes/lets_assemble_comp.tscn"})
			tasks.append({"name": "Installing Operating System", "scene": "res://scenes/installing_os.tscn"})
			tasks.append({"name": "Arrange Cables", "scene": "res://scenes/arrange_cables.tscn"})
			
		# --- INDIVIDUAL TASKS (For other customers) ---
		"issue_computer_hardware":
			tasks.append({
				"name": "Assemble Computer Hardware", 
				"scene": "res://scenes/hardware_assembly.tscn"
			})
			
		"issue_install_operating_system":
			tasks.append({
				"name": "Installing Operating System", 
				"scene": "res://scenes/installing_os.tscn"
			})
			
		"issue_arrange_cables":
			tasks.append({
				"name": "Arrange Cables", 
				"scene": "res://scenes/arrange_cables.tscn"
			})
			
		_:
			# This is a safety catch just in case an unknown ID is sent
			push_error("Taskboard received an unknown issue_id: " + issue_id)
			return 
	
	# Re-populate the UI so the new CheckBox(es) appear!
	_populate_tasks()
func _populate_tasks() -> void:
	# Clear existing children first
	for child in task_list.get_children():
		child.queue_free()

	var is_next_task_locked = false

	for i in range(tasks.size()):
		var task_name = tasks[i]["name"]
		var scene_path = tasks[i]["scene"]
		
		# Create a CheckBox instead of a regular Button
		var cb = CheckBox.new()
		cb.text = task_name
		
		# --- APPLY OUR EXPORTED VARIABLES HERE ---
		cb.alignment = text_alignment
		cb.add_theme_font_size_override("font_size", text_font_size)
		cb.add_theme_color_override("font_color", normal_text_color)
		cb.add_theme_color_override("font_hover_color", hover_text_color)
		cb.add_theme_color_override("font_disabled_color", disabled_text_color)
		# -----------------------------------------
		
		# Check if this task is in our GlobalState completed list
		var is_completed = GlobalState.completed_tasks.has(task_name)
		
		if is_completed:
			# Task is done! Check the box and disable clicking it again.
			cb.button_pressed = true
			cb.disabled = true 
		else:
			# Task is not done.
			cb.button_pressed = false
			
			if is_next_task_locked:
				# A previous task hasn't been completed yet, so keep this one locked.
				cb.disabled = true
			else:
				# This is the CURRENT active task! Leave it enabled.
				cb.disabled = false
				# Because this task is incomplete, ALL tasks after this one must be locked.
				is_next_task_locked = true 
		
		# Connect the scene transition
		cb.pressed.connect(func(): _on_task_clicked(task_name, scene_path))
		
		task_list.add_child(cb)

func _on_task_clicked(task_name: String, target_scene_path: String) -> void:
	# Save the active task to GlobalState so the next scene knows what to do
	GlobalState.current_issue = task_name 
	
	# Jump straight to the assembly scene!
	var err = get_tree().change_scene_to_file(target_scene_path)
	if err != OK:
		push_error("Failed to load scene at path: " + target_scene_path)
func show_board() -> void:
	# Re-populate tasks every time the board is shown to catch any new completions!
	_populate_tasks()
	visible = true

func hide_board() -> void:
	visible = false
