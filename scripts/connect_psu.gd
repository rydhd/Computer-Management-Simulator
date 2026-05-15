extends Control

# Exposes an array in the Inspector so you can easily drag-and-drop your PSU textures.
@export var psu_textures: Array[Texture2D]

# Keeps track of which side (index) we are currently viewing.
var current_side_index: int = 0

# Grab references to our nodes once the scene is ready.
# Note: Ensure these paths match exactly how you named them in your Scene Tree!
@onready var psu_texture_rect: TextureRect = $PSU
@onready var left_button: TextureButton = $LeftArrow
@onready var right_button: TextureButton = $RightArrow

func _ready() -> void:
	# Connect the button signals to our custom functions via code.
	# In Godot 4.x, we use the first-class Callable syntax for signals.
	left_button.pressed.connect(_on_left_arrow_pressed)
	right_button.pressed.connect(_on_right_arrow_pressed)
	
	# Initialize the first texture safely if the array isn't empty
	if psu_textures.size() > 0:
		update_psu_visual()
	else:
		push_warning("PSU Textures array is empty! Please assign textures in the Inspector.")

func _on_left_arrow_pressed() -> void:
	if psu_textures.is_empty(): return
	
	# Move to the previous texture. Wrap around to the end if we go below 0.
	current_side_index -= 1
	if current_side_index < 0:
		current_side_index = psu_textures.size() - 1
		
	update_psu_visual()

func _on_right_arrow_pressed() -> void:
	if psu_textures.is_empty(): return
	
	# Move to the next texture. Wrap around to 0 if we exceed the array size.
	current_side_index += 1
	if current_side_index >= psu_textures.size():
		current_side_index = 0
		
	update_psu_visual()

func update_psu_visual() -> void:
	# Swap the texture on the PSU TextureRect
	psu_texture_rect.texture = psu_textures[current_side_index]
