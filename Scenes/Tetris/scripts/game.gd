extends Control
## Handles Tetris input and display logic
class_name TetrisControl

@export var TILE_SIZE: int = 30
@export var WIDTH = 10
@export var HEIGHT = 20

@export var board_layer: TileMapLayer
@export var preview_layer: TileMapLayer
@export var score_label: Label
@export var lines_label: Label
@export var pieces_placed_label: Label
@export var pause_button: Button 
@export var pause_menu: ColorRect
@export var game_over_menu: ColorRect

var game_state : Tetris = null

var _game_over : bool = false
var _timer := Timer.new()
var _timer_input := Timer.new()
var _is_paused : bool = false

var _ms_started := 0

func _ready() -> void:
	_setup_game()
	
func _setup_game() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	_timer.wait_time = 1
	_timer.timeout.connect(timout_callback)
	add_child(_timer)
	
	_timer_input.wait_time = 0.1
	_timer_input.timeout.connect(go_down)
	add_child(_timer_input)

func _on_pause_button_pressed() -> void:
	pause_menu.show_menu()
	
func start_game() -> void:
	_game_over = false
	game_state = Tetris.new(HEIGHT, WIDTH)
	game_state.game_over.connect(on_game_over)
	game_state.preview_figure.connect(on_draw_next_piece)
	game_state.line_broken.connect(on_line_broken)
	
	game_state.new_figure()
	game_state.pieces_placed = 0
	draw_everything()
	_timer.start()
	_ms_started = Time.get_ticks_msec()

func draw_everything() -> void:
	draw_board()
	draw_score()
	draw_linesBroken()
	draw_piecesPlaced()

func exit_game() -> void:
	draw_everything()

func restart_game() -> void:
	end_game()
	start_game()

func end_game() -> void:
	_game_over = true
	_timer.stop()
	_timer_input.stop()
	
	@warning_ignore("integer_division")
	var stats := {
		"score": game_state.score,
		"lines_broken": game_state.lines_broken,
		"pieces_placed": game_state.pieces_placed,
		"time_played": (Time.get_ticks_msec() - _ms_started) / 1000,
		"date": Time.get_datetime_string_from_system(false, true)}
	
	TetrisStatistics.save_statistic(stats)

## Pauses the game if paused is true
func pause_game(paused: bool) -> void:
	_timer.paused = paused
	_timer_input.paused = paused
	_is_paused = paused
	
## Moves the active tetramino down and draws the board
func go_down() -> void:
	game_state.go_down()
	draw_board()

## On line broken callback - dreaws the score and lines broken
func on_line_broken() -> void:
	draw_score()
	draw_linesBroken()

## Writes the score in [member TetrisControl.score_label]
func draw_score() -> void:
	score_label.text = "Score\n%07d" % game_state.score

## Writes broken line count in [member TetrisControl.lines_label]
func draw_linesBroken() -> void:
	lines_label.text = "Lines\n%07d" % game_state.lines_broken

## Writes placed piece count in [member TetrisControl.pieces_placed_label]
func draw_piecesPlaced() -> void:
	pieces_placed_label.text = "Placed\n%07d" % game_state.pieces_placed
	
## game_state clock callback from [member TetrisControl._timer]
func timout_callback() -> void:
	game_state.go_down();
	draw_board()
	
## Callback from [signal Tetris._game_over] that stops the game
func on_game_over() -> void:
	end_game()
	game_over_menu.show_menu()

## Draws the board and the falling tetramino from [member game_state]
## to [member TetrisControl.board_layer]
func draw_board() -> void:
	# Write the active tetramino and its shadow to the field 
	var field := game_state.field.duplicate(true)
	if game_state.figure != null:
		for row in range(4):
			for col in range(4):
				# Write active tetramino shadow
				var shadow := game_state.get_shadow()
				if row * 4 + col in shadow.image():
					field[row + shadow.y][col + shadow.x] = shadow.color
				# Write active tetramino
				if row * 4 + col in game_state.figure.image():
					field[row + game_state.figure.y][col + game_state.figure.x] = game_state.figure.color
				
	
	# Display the field
	board_layer.clear()
	for row in range(game_state.height):
		for col in range(game_state.width):
			if field[row][col] > 0:
				board_layer.set_cell(Vector2i(col, row), 0, Vector2i(field[row][col] - 1, 0))


## Callback to update next piece preview [member TetrisControl.preview_layer]
func on_draw_next_piece() -> void:
	draw_piecesPlaced()
	preview_layer.clear()
	draw_tetramino(game_state.next_figure, preview_layer)

## Draws the [param tetramino] to [param layer]
static func draw_tetramino(tetramino: Figure, layer: TileMapLayer) -> void:
	if tetramino == null:
		return
	
	for row in range(4):
		for col in range(4):
			if row * 4 + col in tetramino.image():
				layer.set_cell(Vector2i(col, row + 1), 0, Vector2i(tetramino.color - 1, 0))

func _input(event: InputEvent) -> void:
	if _game_over || _is_paused:
		return
	var update := false
	if Input.is_action_just_pressed("ui_down"):
		_timer.stop()
		go_down()
		_timer_input.start()
	if Input.is_action_just_released("ui_down"):
		_timer.start()
		_timer_input.stop()
		
	if event.is_pressed():
		if event.is_action("ui_up"):
			game_state.rotate(); update = true
		elif event.is_action("ui_left"):
			game_state.go_side(-1); update = true
		elif event.is_action("ui_right"):
			game_state.go_side(1); update = true
		elif event.is_action("ui_accept"):
			game_state.go_space(); update = true
		
		if update:
			draw_board()
