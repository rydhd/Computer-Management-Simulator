# res://scripts/tutorial_arrow.gd
extends Sprite2D

# 1. Define our arrow types
enum ArrowType { BELL, TASKBOARD }

# 2. Export it so it appears in the Godot Inspector!
@export var arrow_type: ArrowType = ArrowType.BELL

@export var float_distance: float = 15.0 # How high the arrow bounces
@export var float_speed: float = 0.6     # How long one bounce takes

var _start_y: float
var _float_tween: Tween

func _ready() -> void:
	_start_y = position.y
	
	# Start hidden until the EventBus calls it!
	visible = false
	modulate.a = 0.0
	
	# 3. Check WHICH arrow this is, and connect the right signals!
	if arrow_type == ArrowType.BELL:
		EventBus.show_bell_arrow.connect(start_floating)
		EventBus.npc_arrived.connect(stop_floating)
		
	elif arrow_type == ArrowType.TASKBOARD:
		EventBus.show_taskboard_arrow.connect(start_floating)
		EventBus.hide_taskboard_arrow.connect(stop_floating)

func start_floating() -> void:
	visible = true
	modulate.a = 1.0 # CRITICAL: Reset the alpha to fully opaque before starting!
	
	# Kill existing tween if we restart it
	if _float_tween and _float_tween.is_valid():
		_float_tween.kill()
		
	# Create a tween that loops forever
	_float_tween = create_tween().set_loops()
	
	# 1. Move Up (using SINE transition for a natural ease-in/ease-out)
	_float_tween.tween_property(self, "position:y", _start_y - float_distance, float_speed).set_trans(Tween.TRANS_SINE)
	# 2. Move Down
	_float_tween.tween_property(self, "position:y", _start_y, float_speed).set_trans(Tween.TRANS_SINE)


func stop_floating() -> void:
	print("DEBUG: stop_floating() was triggered!") # <--- Add this!
	
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	
	fade_tween.tween_callback(func():
		print("DEBUG: Fade complete, hiding arrow.") # <--- Add this!
		visible = false
		if _float_tween and _float_tween.is_valid():
			_float_tween.kill()
		position.y = _start_y
	)

func _on_tutorial_progressed() -> void:
	# We check the global state (or you can pass a specific flag). 
	# If the tutorial is waiting for the player to click the bell, show the arrow!
	# You'll need to adapt this slightly based on how you track the exact step,
	# but as a quick trigger:
	pass # We will actually trigger this directly from the manager for better control

func _on_npc_arrived() -> void:
	# When the NPC arrives (or when the bell is clicked), hide the arrow
	stop_floating()
