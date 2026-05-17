extends Control

@onready var begin_button: Button = %BeginButton
@onready var system_unit_sprite: TextureRect = $SystemUnit

const MOBO_INSTALLED_TEX = preload("res://assets/COC 1/Assemble Computer Hardware/Lets Assemble Computer Hardware/System unit.png")

# Start by assuming they are on Task 1
var next_scene_path: String = "res://scenes/COC 1/Assemble Computer Hardware/MOBO Assembly/hardware_assembly.tscn"

func _ready() -> void:
	if begin_button and not begin_button.pressed.is_connected(_on_begin_button_pressed):
		begin_button.pressed.connect(_on_begin_button_pressed)
		
	# Setup Default Button state (Task 1)
	if begin_button:
		begin_button.disabled = false
		begin_button.text = "Assemble MOBO"
		begin_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	print("--- MENU LOADED ---")
	print("Current GlobalState array: ", GlobalState.completed_tasks)
	
	# --- CASCADING LOGIC TO OVERWRITE THE BUTTON ---
	
	if "Fix PC: System Unit Installation" in GlobalState.completed_tasks:
		if system_unit_sprite:
			system_unit_sprite.texture = MOBO_INSTALLED_TEX
			system_unit_sprite.scale = Vector2(1.3, 1.8)
		_setup_task_2()
		
		
	if "Insert Cables" in GlobalState.completed_tasks:
		_setup_task_4()
		
	if "Test PC" in GlobalState.completed_tasks:
		_setup_all_done()


# --- HELPER FUNCTIONS FOR SCENE PATHS ---

func _setup_task_2() -> void:
	begin_button.text = "Connect PSU"
	# IMPORTANT: Update this path to your actual PSU scene!
	next_scene_path = "res://scenes/COC 1/Assemble Computer Hardware/Insert Cables/insert_cables.tscn" 
	
func _setup_task_4() -> void:
	begin_button.text = "Test PC"
	# IMPORTANT: Update this path to your actual Test scene!
	next_scene_path = "res://scenes/COC 1/Assemble Computer Hardware/test_phase.tscn"

func _setup_all_done() -> void:
	begin_button.text = "Return to Shop"
	next_scene_path = "res://scenes/shop_2d.tscn"


# --- CLICKING THE BUTTON ---
func _on_begin_button_pressed() -> void:
	var err = get_tree().change_scene_to_file(next_scene_path)
	if err != OK:
		push_error("Failed to load scene. Check this file path: " + next_scene_path)
