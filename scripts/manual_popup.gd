extends CanvasLayer

# ==========================================
# NODE REFERENCES
# ==========================================
@onready var close_button: Button = $BookCenter/BookBackground/CloseButton
@onready var book_background: TextureRect = $BookCenter/BookBackground # <--- ADD THIS LINE

# Tab Buttons
@onready var parts_button: Button = $BookCenter/TabButtonsHBox/PartsButton
@onready var errors_button: Button = $BookCenter/TabButtonsHBox/ErrorsButton

# Navigation Updates
@onready var left_button: TextureButton = $BookCenter/BookBackground/NavigationHBox/LeftButton
@onready var right_button: TextureButton = $BookCenter/BookBackground/NavigationHBox/RightButton
@onready var page_label: Label = $BookCenter/BookBackground/NavigationHBox/Label

# Right Page Updates
@onready var page_text: RichTextLabel = $BookCenter/BookBackground/RightPage/RightVBox/PageText

# Left Page Updates
@onready var title_label: Label = $BookCenter/BookBackground/LeftPage/LeftVBox/TitleLabel
@onready var page_image: TextureRect = $BookCenter/BookBackground/LeftPage/LeftVBox/PageImage

# ==========================================
# STATE & DATA
# ==========================================
var current_page: int = 0
var active_pages: Array[Dictionary] = []

# --- BACKGROUND TEXTURES ---
# Preload your default Parts journal image
var parts_bg_texture: Texture2D = preload("res://assets/2D Assets/2D Materials/Journal Overlay 1.png")

# Preload your new Errors journal image (REPLACE THIS PATH WITH YOUR ACTUAL IMAGE PATH!)
var errors_bg_texture: Texture2D = preload("res://assets/2D Assets/2D Materials/Journal Overlay 2.png")
# This variable holds whichever array we are currently looking at!


# --- DATABASE 1: PARTS ---
var parts_pages: Array[Dictionary] = [
	{
		"title": "Introduction",
		"text": "Welcome to your new PC repair shop!\n\nHere you will learn how to identify, repair, and install hardware components.",
		"image": null
	},
	{
		"title": "The CPU (Processor)",
		"text": "[b]What does it do?[/b]\nThe Central Processing Unit is the brain of the computer.\n\n[color=red]WARNING:[/color] Always ensure thermal paste is applied before attaching the cooler!",
		"image": null
	}
]

# --- DATABASE 2: ERRORS ---
var errors_pages: Array[Dictionary] = [
	{
		"title": "Blue Screen of Death (BSOD)",
		"text": "[b]What is it?[/b]\nA fatal system error indicating the operating system has crashed.\n\n[b]Common Causes:[/b]\n1. Faulty RAM\n2. Overheating CPU\n3. Corrupt Drivers",
		
		# REPLACE "null" WITH YOUR IMAGE PATH!
		"image": null # Put your exact image path here!
	},
	{
		"title": "No POST (Power On Self Test)",
		"text": "[b]Symptoms:[/b]\nThe computer turns on, fans spin, but the screen stays black and there are no beeps.\n\n[b]Solution:[/b]\nCheck if the RAM is fully seated and the CPU power cable is plugged in.",
		
		# You can leave this as null if this specific page doesn't need an image
		"image": null 
	}
]

# ==========================================
# BUILT-IN FUNCTIONS
# ==========================================
func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	
	# Connect the new tab buttons!
	parts_button.pressed.connect(_on_parts_button_pressed)
	errors_button.pressed.connect(_on_errors_button_pressed)
	
	hide()
	
	# Set default tab to Parts when the game loads
	_on_parts_button_pressed()

# ==========================================
# CORE LOGIC
# ==========================================
func update_page_display() -> void:
	if active_pages.is_empty():
		return
		
	var page_data = active_pages[current_page]
	
	title_label.text = page_data["title"]
	page_text.clear()
	page_text.append_text(page_data["text"])
	
	if page_data["image"] != null:
		page_image.texture = page_data["image"]
		page_image.show()
	else:
		page_image.hide()
		
	page_label.text = str(current_page + 1) + " / " + str(active_pages.size())
	
	# Disable buttons dynamically based on the active array size
	left_button.disabled = (current_page == 0)
	right_button.disabled = (current_page == active_pages.size() - 1)

# ==========================================
# SIGNAL CALLBACKS
# ==========================================
func _on_parts_button_pressed() -> void:
	active_pages = parts_pages  
	current_page = 0            
	
	# SWAP THE BACKGROUND IMAGE!
	book_background.texture = parts_bg_texture
	
	parts_button.disabled = true
	errors_button.disabled = false
	
	update_page_display()

func _on_errors_button_pressed() -> void:
	active_pages = errors_pages 
	current_page = 0            
	
	# SWAP THE BACKGROUND IMAGE!
	book_background.texture = errors_bg_texture
	
	errors_button.disabled = true
	parts_button.disabled = false
	
	update_page_display()

func _on_left_button_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		update_page_display()

func _on_right_button_pressed() -> void:
	if current_page < active_pages.size() - 1:
		current_page += 1
		update_page_display()

func _on_close_button_pressed() -> void:
	hide()

# ==========================================
# PUBLIC API
# ==========================================
func open_manual() -> void:
	show()
