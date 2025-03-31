extends Control

var grid_size = GameDifficulty.difficulty
@export var cell_size := 64
@export var cell_spacing := 4

func _ready():
	# Configure root Control to fill the screen
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
	
	# Center the grid - METHOD 1 (Recommended)
	grid.anchors_preset = Control.PRESET_CENTER
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Alternative METHOD 2 (Manual positioning)
	var viewport_size = get_viewport_rect().size
	grid.position = (viewport_size - Vector2(total_width, total_height)) * 0.5
	
	# Set spacing
	grid.add_theme_constant_override("hseparation", cell_spacing)
	grid.add_theme_constant_override("vseparation", cell_spacing)
	
	add_child(grid)
	
	# Create buttons
	for i in grid_size * grid_size:
		var button = Button.new()
		button.custom_minimum_size = Vector2(cell_size, cell_size)
		button.toggle_mode = true
		button.pressed.connect(_on_button_pressed.bind(i))
		grid.add_child(button)
	
	# Force layout update
	await get_tree().process_frame
	print("Final grid position: ", grid.position)
	print("Grid size: ", grid.size)
	print("Viewport size: ", get_viewport_rect().size)

func _on_button_pressed(index: int):
	print("Button pressed: ", index)
