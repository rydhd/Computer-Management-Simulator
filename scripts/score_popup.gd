extends CanvasLayer

@onready var details_label: RichTextLabel = %DetailsLabel
@onready var total_score_label: Label = %TotalScoreLabel
@onready var close_button: Button = %CloseButton
@onready var payment_sound: AudioStreamPlayer = $PaymentSound
# Signal to tell the shop scene we are done looking at the scores
signal closed

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)

func display_scores(active_tasks_array: Array) -> void:
	var formatted_text: String = ""
	var total_score: int = 0
	var valid_tasks: int = 0

	# Loop through the tasks the customer asked for
	for task in active_tasks_array:
		var task_name: String = task["name"]
		
		# Check if we have a recorded score for this task
		if GlobalState.task_scores.has(task_name):
			var data = GlobalState.task_scores[task_name]
			# Format the text with BBCode for bolding
			formatted_text += "[b]%s[/b]\nTime: %s sec | Score: %d/100\n\n" % [task_name, str(data["time_taken"]), data["score"]]
			total_score += data["score"]
			valid_tasks += 1
		else:
			formatted_text += "[b]%s[/b]\nNo timer data recorded.\n\n" % task_name

	details_label.text = formatted_text

	# Calculate the final average grade
	if valid_tasks > 0:
		var average: int = total_score / valid_tasks
		total_score_label.text = "Overall Grade: %d/100" % average
		
		# Optional: Add color coding based on grade
		if average >= 90:
			total_score_label.add_theme_color_override("font_color", Color(0, 1, 0)) # Green
		elif average >= 70:
			total_score_label.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow
		else:
			total_score_label.add_theme_color_override("font_color", Color(1, 0, 0)) # Red
	else:
		total_score_label.text = "Overall Grade: N/A"

func _on_close_pressed() -> void:
	payment_sound.play
	closed.emit()
	queue_free()
