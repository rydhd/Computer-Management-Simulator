extends Area2D

var is_open: bool = false
var is_spinning: bool = false # NEW: Tracks if the circle should be rotating

@export var closed_socket_texture: Texture2D
@export var open_socket_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var spinning_circle: Sprite2D = $SpinningCircle # NEW: Reference to the circle
@onready var latch_button: TextureButton = $LatchButton

func _ready() -> void:
	if closed_socket_texture and sprite:
		sprite.texture = closed_socket_texture
	
	# Ensure the circle is hidden on startup
	if spinning_circle:
		spinning_circle.visible = false

# NEW: The _process function runs every single frame
func _process(delta: float) -> void:
	# If our flag is true, rotate the circle!
	if is_spinning and spinning_circle:
		# Rotate by 10 radians per second. Adjust this number to spin faster/slower!
		spinning_circle.rotation += 10.0 * delta

func open_latch() -> void:
	is_open = true
	if open_socket_texture and sprite:
		sprite.texture = open_socket_texture
	print("CPU Socket latch lifted! Ready for CPU insertion.")

# UPDATED: The button press now triggers the spin sequence
func _on_latch_button_pressed() -> void:
	if not is_open and not is_spinning:
		# 1. Disable the button immediately so they can't spam click it
		latch_button.disabled = true 
		
		# 2. Show the circle and start the spinning logic
		spinning_circle.visible = true
		is_spinning = true
		
		# 3. Create a timer to wait for 1.5 seconds (the "interaction" time)
		# The 'await' keyword pauses this specific function's execution until the timer finishes
		await get_tree().create_timer(1.5).timeout 
		
		# 4. Stop spinning and hide the circle
		is_spinning = false
		spinning_circle.visible = false
		
		# 5. Finally, execute the visual change and state update
		open_latch()
