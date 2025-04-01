extends Control

var grid_size = GameDifficulty.difficulty
@export var cell_size := 64
@export var cell_spacing := 4
var rng = RandomNumberGenerator.new()

# Predefined colors
const COLOR_RED = Color("#ff5555")
const COLOR_GREEN = Color("#55ff55")
const COLOR_DARK = Color("#333333")

func _ready():
	rng.randomize()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	create_centered_grid()

func create_centered_grid():
	# Clear previous grid if exists
	for child in get_children():
		if child.name == "GameGrid":
			child.queue_free()
	
	var grid = GridContainer.new()
	grid.columns = grid_size
	grid.name = "GameGrid"
	
	# Calculate grid dimensions
	var total_width = (cell_size * grid_size) + (cell_spacing * (grid_size - 1))
	var total_height = total_width
	
	# Set grid container size
	grid.custom_minimum_size = Vector2(total_width, total_height)
	
	# Center the grid (using manual positioning)
	var viewport_size = get_viewport_rect().size
	grid.position = (viewport_size - Vector2(total_width, total_height)) * 0.5
	
	# Set spacing
	grid.add_theme_constant_override("hseparation", cell_spacing)
	grid.add_theme_constant_override("vseparation", cell_spacing)
	
	add_child(grid)
	
	# Create styled buttons
	var red_style = create_button_style(COLOR_RED)
	var green_style = create_button_style(COLOR_GREEN)
	
	# Create cells with random colors
	for i in grid_size * grid_size:
		var button = Button.new()
		button.custom_minimum_size = Vector2(cell_size, cell_size)
		button.toggle_mode = true
		
		# Set random initial color (50/50 chance)
		if rng.randf() < 0.5:
			button.add_theme_stylebox_override("normal", red_style)
			button.set_meta("is_green", false)
			button.add_theme_stylebox_override("pressed", create_button_style(COLOR_RED.darkened(0.3)))
		else:
			button.add_theme_stylebox_override("normal", green_style)
			button.set_meta("is_green", true)
			button.add_theme_stylebox_override("pressed", create_button_style(COLOR_GREEN.darkened(0.3)))
		
		button.pressed.connect(_on_button_pressed.bind(button, red_style, green_style))
		grid.add_child(button)
	
	await get_tree().process_frame
	print("Grid created with size: ", grid_size, "x", grid_size)

func create_button_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_DARK
	return style

func _on_button_pressed(button: Button, red_style: StyleBoxFlat, green_style: StyleBoxFlat):
	# Toggle the color state
	var is_green = !button.get_meta("is_green")
	button.set_meta("is_green", is_green)
	
	# Update visual styles
	if is_green:
		button.add_theme_stylebox_override("normal", green_style)
		button.add_theme_stylebox_override("pressed", create_button_style(COLOR_GREEN.darkened(0.3)))
	else:
		button.add_theme_stylebox_override("normal", red_style)
		button.add_theme_stylebox_override("pressed", create_button_style(COLOR_RED.darkened(0.3)))
	
	print("Button toggled to: ", "green" if is_green else "red")
