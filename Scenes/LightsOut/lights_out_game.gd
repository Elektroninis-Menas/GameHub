extends Control

var grid_size = GameDifficulty.difficulty
@export var cell_size := 64
@export var cell_spacing := 4
var rng = RandomNumberGenerator.new()
@onready var victory_label: Label = $VictoryLabel
@onready var difficulty_name: Label = $"Difficulty name"
@onready var pressed_counter: Label = $PressedCounter
@onready var highscore_counter: Label = $HighscoreCounter
@onready var timer_label: Label = $TimerLabel

var counter = 0
var high_scores = {}  # Dictionary to store high scores for each difficulty
var game_timer: float = 0.0
var is_timer_running: bool = false
var best_times = {}  # Dictionary to store best times for each difficulty

# Predefined colors
const COLOR_RED = Color("#ff5555")
const COLOR_GREEN = Color("#55ff55")
const COLOR_DARK = Color("#333333")

var buttons : Array[Array] = []  # 2D array to store button references


func _ready():
	# Load saved high scores
	load_high_scores()

	victory_label.visible = false
	rng.randomize()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	create_valid_grid()

	match grid_size:
		3:
			difficulty_name.text = "Easy"
		5:
			difficulty_name.text = "Medium"
		7:
			difficulty_name.text = "Hard"

	counter = 0
	pressed_counter.text = str(counter)

	# Display high score for current difficulty
	var difficulty_key = str(grid_size)
	if high_scores.has(difficulty_key):
		highscore_counter.text = str(high_scores[difficulty_key])
	else:
		highscore_counter.text = "None"
	
	start_timer()
	if best_times.has(str(grid_size)):
		timer_label.text = format_time(best_times[str(grid_size)])
	else:
		timer_label.text = "00:00"

func _process(delta):
	if is_timer_running:
		game_timer += delta
		timer_label.text = format_time(game_timer)

func start_timer():
	game_timer = 0.0
	is_timer_running = true
	timer_label.text = "00:00"

func stop_timer():
	is_timer_running = false
	
	# Save best time if it's better than previous
	var difficulty_key = str(grid_size)
	if not best_times.has(difficulty_key) or game_timer < best_times[difficulty_key]:
		best_times[difficulty_key] = game_timer
		save_best_times()

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func load_best_times():
	var file = FileAccess.open("user://best_times.json", FileAccess.READ)
	if file:
		best_times = JSON.parse_string(file.get_as_text())
		if best_times == null:
			best_times = {}
		file.close()
	else:
		best_times = {}

func save_best_times():
	var file = FileAccess.open("user://best_times.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(best_times))
		file.close()

func load_high_scores():
	var file = FileAccess.open("user://high_scores.json", FileAccess.READ)
	if file:
		high_scores = JSON.parse_string(file.get_as_text())
		if high_scores == null:
			high_scores = {}
		file.close()
	else:
		high_scores = {}


func save_high_scores():
	var file = FileAccess.open("user://high_scores.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(high_scores))
		file.close()


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
				button.add_theme_stylebox_override("pressed", red_style)
				button.set_meta("is_green", false)
			else:
				button.add_theme_stylebox_override("normal", green_style)
				button.add_theme_stylebox_override("pressed", green_style)
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
	toggle_button(x - 1, y, red_style, green_style)
	toggle_button(x + 1, y, red_style, green_style)
	toggle_button(x, y - 1, red_style, green_style)
	toggle_button(x, y + 1, red_style, green_style)

	counter += 1
	pressed_counter.text = str(counter)

	if all_green():
		victory_label.visible = true
		print("Victory! All buttons are green")

		var difficulty_key = str(grid_size)
		if not high_scores.has(difficulty_key) or high_scores[difficulty_key] > counter:
			high_scores[difficulty_key] = counter
			highscore_counter.text = str(counter)
			save_high_scores()
	
	if all_green():
		victory_label.visible = true
		stop_timer()  # Stop timer when puzzle is solved
		# [Rest of victory code...]


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
	# Reset only the current game, not high scores
	counter = 0
	pressed_counter.text = str(counter)
	victory_label.visible = false
	start_timer()  # Restart timer on reset
	create_valid_grid()
