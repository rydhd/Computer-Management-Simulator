extends Control

@onready var begin_button: Button = %BeginButton

# Grab a reference to your System Unit Sprite2D
@onready var system_unit_sprite: TextureRect = $SystemUnit

# Preload your new texture. 
# IMPORTANT: Update this string with the actual path to your new PNG!
const MOBO_INSTALLED_TEX = preload("res://assets/COC 1/Assemble Computer Hardware/Lets Assemble Computer Hardware/System unit.png")

var next_scene_path: String = "res://scenes/COC 1/Assemble Computer Hardware/MOBO Assembly/hardware_assembly.tscn"

func _ready() -> void:
	if begin_button and not begin_button.pressed.is_connected(_on_begin_button_pressed):
		begin_button.pressed.connect(_on_begin_button_pressed)
		
	if begin_button:
		begin_button.disabled = false
		begin_button.text = "Begin Task 1"
		begin_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# --- DEBUGGING LINES ---
	print("--- MENU LOADED ---")
	print("Current GlobalState array: ", GlobalState.completed_tasks)
	# -----------------------
	
	# If Task 1 is done, setup Task 2 AND replace the image!
	if "Fix PC: System Unit Installation" in GlobalState.completed_tasks:
		_setup_task_2()
		
		if system_unit_sprite:
			system_unit_sprite.texture = MOBO_INSTALLED_TEX
			
			# FIX: Manually set a new scale for the new image.
			# You will need to play with these numbers until it looks right!
			# Try starting with something like 0.2, 0.2 or 0.5, 0.5
			system_unit_sprite.scale = Vector2(1.3, 1.8)
	else:
		print("FAILED: The exact string 'Fix PC: System Unit Installation' was NOT found in the array.")
func _setup_task_2() -> void:
	if begin_button:
		begin_button.disabled = false 
		begin_button.text = "Insert Cables"
		# CRITICAL: Change the destination path to your new scene!
		# Make sure this perfectly matches your	 PSU scene's file path.
		next_scene_path = "res://scenes/COC 1/Assemble Computer Hardware/Insert Cables/insert_cables.tscn" 

func _on_begin_button_pressed() -> void:
	print("Button was pressed. Navigating to: ", next_scene_path)
	
	# FIX: We now use the variable instead of the hardcoded string!
	var error = get_tree().change_scene_to_file(next_scene_path)
	
	if error != OK:
		print("scene change with error code: ", error)
