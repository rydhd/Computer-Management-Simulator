extends CanvasLayer

# ==========================================
# NODE REFERENCES
# ==========================================
@onready var close_button: Button = $BookCenter/BookBackground/CloseButton

# Right Page Updates
@onready var left_button: Button = $BookCenter/BookBackground/NavigationHBox/LeftButton
@onready var right_button: Button = $BookCenter/BookBackground/NavigationHBox/RightButton
@onready var page_label: Label = $BookCenter/BookBackground/NavigationHBox/Label
@onready var page_text: RichTextLabel = $BookCenter/BookBackground/RightPage/RightVBox/PageText

# Left Page Updates
@onready var title_label: Label = $BookCenter/BookBackground/LeftPage/LeftVBox/TitleLabel
@onready var page_image: TextureRect = $BookCenter/BookBackground/LeftPage/LeftVBox/PageImage

# ==========================================
# STATE & DATA
# ==========================================
var current_page: int = 0

# An Array of Dictionaries acts as our local database for the book's contents.
var manual_pages: Array[Dictionary] = [
	{
		"title": "Introduction",
		"text": "Welcome to your new PC repair shop!\n\nHere you will learn how to identify, repair, and install hardware components. Use the buttons below to flip through the manual.",
		"image": null
	},
	{
		"title": "The CPU (Processor)",
		"text": "[b]What does it do?[/b]\nThe Central Processing Unit is the brain of the computer. It handles all the complex calculations and instructions.\n\n[b]Installation Steps:[/b]\n1. Lift the socket lever.\n2. Align the golden triangle.\n3. Drop it in gently.\n\n[color=red]WARNING:[/color] Always ensure thermal paste is applied before attaching the cooler!",
		"image": null
	},
	{
		"title": "Graphics Processing Unit",
		"text": "[b]What does it do?[/b]\nThe [color=green]GPU[/color] renders images, video, and 2D/3D graphics. \n\nIt slots into the PCIe lane on the motherboard. Always ensure it is seated properly and the power cables are connected.",
		"image": null
	}
]

# ==========================================
# BUILT-IN FUNCTIONS
# ==========================================
func _ready() -> void:
	# 1. Connect signals using Godot 4.x syntax
	close_button.pressed.connect(_on_close_button_pressed)
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	
	# 2. Hide the manual by default when the scene loads
	hide()
	
	# 3. Initialize the visual state
	update_page_display()

# ==========================================
# CORE LOGIC
# ==========================================
func update_page_display() -> void:
	if manual_pages.is_empty():
		return
		
	var page_data = manual_pages[current_page]
	
	# Populate Title
	title_label.text = page_data["title"]
	
	# Populate RichTextLabel securely 
	page_text.clear()
	# Using append_text parses BBCode correctly (like bolding and colors!)
	page_text.append_text(page_data["text"])
	
	# Populate Image (Hide TextureRect if there's no image for this page to save space)
	if page_data["image"] != null:
		page_image.texture = page_data["image"]
		page_image.show()
	else:
		page_image.hide()
		
	# Update Navigation UI
	page_label.text = str(current_page + 1) + " / " + str(manual_pages.size())
	
	# Disable buttons if we are at the beginning or end of the book
	left_button.disabled = (current_page == 0)
	right_button.disabled = (current_page == manual_pages.size() - 1)

# ==========================================
# SIGNAL CALLBACKS
# ==========================================
func _on_left_button_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		update_page_display()

func _on_right_button_pressed() -> void:
	if current_page < manual_pages.size() - 1:
		current_page += 1
		update_page_display()

func _on_close_button_pressed() -> void:
	# Hide the CanvasLayer entirely
	hide()

# ==========================================
# PUBLIC API
# ==========================================
func open_manual() -> void:
	current_page = 0
	update_page_display()
	show()
