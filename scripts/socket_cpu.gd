extends Area2D

# 1. Define a signal to tell the main assembly script when the socket state changes
signal socket_toggled(is_open: bool)

var is_open: bool = false
var is_spinning: bool = false 

@export var closed_socket_texture: Texture2D
@export var open_socket_texture: Texture2D

# 2. Get a reference to the main background TextureRect instead of the hidden Sprite2D
@onready var main_mobo_bg: TextureRect = $"../MotherboardClosedAndColoredBgRemovedf"
@onready var spinning_circle: Sprite2D = $SpinningCircle 
@onready var latch_button: TextureButton = $"../LatchButton"

func _ready() -> void:
	# Initialize the background to the closed texture on startup
	if closed_socket_texture and main_mobo_bg:
		main_mobo_bg.texture = closed_socket_texture
	
	if spinning_circle:
		spinning_circle.visible = false

func _process(delta: float) -> void:
	if is_spinning and spinning_circle:
		spinning_circle.rotation += 10.0 * delta

# 3. Consolidate into a single toggle function
func toggle_latch() -> void:
	is_open = !is_open # Flip the boolean state
	
	if is_open:
		print("CPU Socket latch lifted! Ready for CPU insertion.")
		if open_socket_texture and main_mobo_bg:
			main_mobo_bg.texture = open_socket_texture
	else:
		print("CPU Socket latch closed!")
		if closed_socket_texture and main_mobo_bg:
			main_mobo_bg.texture = closed_socket_texture
			
	# Emit the signal so the main script knows the state changed
	socket_toggled.emit(is_open)

func _on_latch_button_pressed() -> void:
	# Only allow clicking if the animation isn't currently running
	if not is_spinning:
		# Temporarily disable the button to prevent spam-clicking
		latch_button.disabled = true 
		
		spinning_circle.visible = true
		is_spinning = true
		
		await get_tree().create_timer(1.5).timeout 
		
		is_spinning = false
		spinning_circle.visible = false
		
		# Execute the visual change and state update
		toggle_latch()
		
		# Re-enable the button so the player can click it again to close/open
		latch_button.disabled = false
