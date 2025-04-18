extends Control

var grid_size = GameDifficulty.difficulty
@export var cell_size := 64
@export var cell_spacing := 4
var rng = RandomNumberGenerator.new()
@onready var victory_label: Label = $VictoryLabel

# Predefined colors
const COLOR_RED = Color("#ff5555")
const COLOR_GREEN = Color("#55ff55")
const COLOR_DARK = Color("#333333")

var buttons = []  # 2D array to store button references

func _ready():
	victory_label.visible = false
	rng.randomize()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	create_valid_grid()

func create_valid_grid():
	var valid_grid = false
	while not valid_grid:
		create_centered_grid()
		valid_grid = has_red_buttons()
		if not valid_grid:
			print("Regenerating grid (all buttons were green)")
			for child in get_children():
				if child.name == "GameGrid":
					child.queue_free()

func has_red_buttons() -> bool:
	for y in grid_size:
		for x in grid_size:
			if buttons[x][y] and not buttons[x][y].get_meta("is_green"):
				return true
	return false

func all_green() -> bool:
	for y in grid_size:
		for x in grid_size:
			if buttons[x][y] and not buttons[x][y].get_meta("is_green"):
				return false
	return true

func create_centered_grid():
	for child in get_children():
		if child.name == "GameGrid":
			child.queue_free()
	
	buttons = []
	var grid = GridContainer.new()
	grid.columns = grid_size
	grid.name = "GameGrid"
	
	var total_width = (cell_size * grid_size) + (cell_spacing * (grid_size - 1))
	var total_height = total_width
	
	grid.custom_minimum_size = Vector2(total_width, total_height)
	var viewport_size = get_viewport_rect().size
	grid.position = (viewport_size - Vector2(total_width, total_height)) * 0.5
	
	grid.add_theme_constant_override("hseparation", cell_spacing)
	grid.add_theme_constant_override("vseparation", cell_spacing)
	
	add_child(grid)
	
	# Create styled buttons with identical pressed/unpressed colors
	var red_style = create_button_style(COLOR_RED)
	var green_style = create_button_style(COLOR_GREEN)
	
	buttons.resize(grid_size)
	for i in grid_size:
		buttons[i] = []
		buttons[i].resize(grid_size)
	
	for y in grid_size:
		for x in grid_size:
			var button = Button.new()
			button.custom_minimum_size = Vector2(cell_size, cell_size)
			button.toggle_mode = true
			
			if rng.randf() < 0.5:
				button.add_theme_stylebox_override("normal", red_style)
				button.add_theme_stylebox_override("pressed", red_style)  # Same style
				button.set_meta("is_green", false)
			else:
				button.add_theme_stylebox_override("normal", green_style)
				button.add_theme_stylebox_override("pressed", green_style)  # Same style
				button.set_meta("is_green", true)
			
			button.pressed.connect(_on_button_pressed.bind(x, y, red_style, green_style))
			grid.add_child(button)
			buttons[x][y] = button
	
	await get_tree().process_frame
	print("Grid created with size: ", grid_size, "x", grid_size)

func create_button_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = COLOR_DARK
	return style

func _on_button_pressed(x: int, y: int, red_style: StyleBoxFlat, green_style: StyleBoxFlat):
	toggle_button(x, y, red_style, green_style)
	toggle_button(x-1, y, red_style, green_style)
	toggle_button(x+1, y, red_style, green_style)
	toggle_button(x, y-1, red_style, green_style)
	toggle_button(x, y+1, red_style, green_style)
	
	if all_green():
		victory_label.visible = true
		print("Victory! All buttons are green")

func toggle_button(x: int, y: int, red_style: StyleBoxFlat, green_style: StyleBoxFlat):
	if x >= 0 and x < grid_size and y >= 0 and y < grid_size:
		var button = buttons[x][y]
		if button:
			var is_green = !button.get_meta("is_green")
			button.set_meta("is_green", is_green)
			
			if is_green:
				button.add_theme_stylebox_override("normal", green_style)
				button.add_theme_stylebox_override("pressed", green_style)
			else:
				button.add_theme_stylebox_override("normal", red_style)
				button.add_theme_stylebox_override("pressed", red_style)


func _on_button_2_pressed() -> void:
	_ready()
	if victory_label.visible == true:
		victory_label.visible = false
