extends Control

# Node References
@onready var dialogue_text: RichTextLabel = $ColorRect/ReferenceRect/DialogueText
@onready var welcome_screen: ColorRect = $WelcomeScreen
@onready var loading_screen: ColorRect = $LoadingScreen
@onready var loading_bar: ProgressBar = $LoadingScreen/LoadingBar

# --- NEW AUDIO REFERENCES ---
@onready var typing_sound: AudioStreamPlayer = $TypingSound
@onready var typing_timer: Timer = $TypingTimer

# Dialogue Data
var dialogue_lines: Array[String] = [
	"MY NAME'S RENIER. I LIVE WITH MY DAD IN A SMALL NEIGHBORHOOD THAT'S SEEN BETTER DAYS. PEOPLE HERE DON'T HAVE MUCH, BUT THEY MAKE DO. WE RUN A TINY COMPUTER REPAIR SHOP AT THE CORNER OF THE STREET. IT'S NOTHING FANCY-JUST SHELVES OF OLD PARTS, WIRES HANGING EVERYWHERE, AND MACHINES THAT HAVE MORE HISTORY THAN LIFE LEFT IN THEM.",
	"THIS SHOP USED TO BE FULL OF ENERGY WHEN DAD WAS WELL. HE COULD FIX ANYTHING, NO MATTER HOW BROKEN. CUSTOMERS TRUSTED HIM, NOT JUST BECAUSE OF HIS SKILL, BUT BECAUSE HE NEVER GAVE UP ON A MACHINE-OR ON PEOPLE. BUT NOW, WITH HIM TOO SICK TO WORK, IT'S ALL ON ME.",
	"I'M NOT AS FAST AS HE WAS, AND SOMETIMES I MAKE MISTAKES. BUT I KEEP TRYING. EVERY REPAIR I FINISH, EVERY LITTLE BIT OF MONEY I SAVE-IT ALL BRINGS ME CLOSER TO WHAT I REALLY NEED: ENOUGH TO BUY HIS MEDICINE. I KNOW IT WON'T BE EASY, BUT I HAVE TO DO IT.",
	"THIS IS WHERE MY JOURNEY BEGINS. JUST ME, THIS OLD SHOP, AND A PROMISE TO BRING MY FATHER BACK TO HEALTH. I DON'T KNOW WHAT CHALLENGES LIE AHEAD, BUT I'LL FACE THEM ONE AT A TIME... STARTING TODAY."
]

var current_line_index: int = 0
var tween: Tween
var type_speed: float = 0.05

# State Management
enum State { DIALOGUE, WELCOME, LOADING }
var current_state: State = State.DIALOGUE

func _ready() -> void:
	# Ensure the overlay screens are hidden at the start
	welcome_screen.hide()
	loading_screen.hide()
	loading_bar.value = 0 # Ensure the bar starts empty
	
	# Connect the typing timer
	typing_timer.timeout.connect(_on_typing_timer_timeout)
	
	show_current_line()

func _on_typing_timer_timeout() -> void:
	# Add pitch variation to make the text sound more natural and less repetitive!
	typing_sound.pitch_scale = randf_range(0.95, 1.05)
	typing_sound.play()

func show_current_line() -> void:
	dialogue_text.text = dialogue_lines[current_line_index]
	dialogue_text.visible_characters = 0
	
	var total_characters: int = dialogue_text.get_total_character_count()
	var duration: float = total_characters * type_speed
	
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(dialogue_text, "visible_characters", total_characters, duration)
	
	# --- START THE TYPING SOUND ---
	typing_timer.start(type_speed)
	
	# Tell the timer to stop exactly when the tween finishes typing
	tween.finished.connect(func(): typing_timer.stop())

func _input(event: InputEvent) -> void:
	var is_click: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	var is_accept: bool = event.is_action_pressed("ui_accept")
	
	if is_click or is_accept:
		match current_state:
			State.DIALOGUE:
				handle_dialogue_input()
			State.WELCOME:
				start_loading()
			State.LOADING:
				pass # Ignore input while loading

func handle_dialogue_input() -> void:
	if tween and tween.is_running():
		# Skip typing animation
		tween.kill()
		dialogue_text.visible_characters = -1
		
		# --- STOP THE TYPING SOUND IMMEDIATELY ---
		typing_timer.stop()
	else:
		# Move to next line
		current_line_index += 1
		
		if current_line_index < dialogue_lines.size():
			show_current_line()
		else:
			# End of dialogue, show Welcome Screen
			show_welcome_screen()

func show_welcome_screen() -> void:
	current_state = State.WELCOME
	welcome_screen.show()

func start_loading() -> void:
	current_state = State.LOADING
	welcome_screen.hide()
	loading_screen.show()
	
	# Animate the progress bar from 0 to 100 over 1.5 seconds
	loading_bar.value = 0
	var load_tween: Tween = create_tween()
	load_tween.tween_property(loading_bar, "value", 100, 1.5)
	
	# Wait for the exact same duration as the progress bar animation
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
