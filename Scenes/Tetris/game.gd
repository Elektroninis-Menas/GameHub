extends Control
class_name TetrisControl

@onready var board_layer: TileMapLayer = $Layers/Board/board
@onready var preview_layer: TileMapLayer = $"Layers/Side Panel/Preview/preview"

@onready var score_label: Label = $"Layers/Side Panel/Score/Label"
@onready var lines_label: Label = $"Layers/Side Panel/Lines/Label"
@onready var placed_label: Label = $"Layers/Side Panel/Placed/Label"

const TILE_SIZE = 30
const WIDTH = 10
const HEIGHT = 20

var game : Tetris = null

var _game_over : bool = false
var _timer := Timer.new()
var _timer_input := Timer.new()
var _is_paused : bool = false

var _ms_started := 0
var time_played := 0

func _ready() -> void:
	_setup_game()
	
func _setup_game() -> void:
	_timer.wait_time = 1
	_timer.timeout.connect(timout_callback)
	add_child(_timer)
	
	_timer_input.wait_time = 0.1
	_timer_input.timeout.connect(go_down)
	add_child(_timer_input)


func start_game() -> void:
	game = Tetris.new(HEIGHT, WIDTH)
	game.game_over.connect(on_game_over)
	game.preview_figure.connect(on_draw_next_piece)
	game.on_line_broken.connect(on_line_broken)
	
	game.new_figure()
	game.pieces_placed = 0
	draw_board()
	draw_score()
	draw_linesBroken()
	draw_piecesPlaced()
	_timer.start()
	_ms_started = Time.get_ticks_msec()
	
func end_game() -> void:
	@warning_ignore("integer_division")
	time_played = (Time.get_ticks_msec() - _ms_started) / 1000
	draw_board()
	draw_linesBroken()
	draw_piecesPlaced()
	draw_score()

## Pauses the game if paused is true
func pause_game(paused: bool) -> void:
	_timer.paused = paused
	_timer_input.paused = paused
	_is_paused = paused
	
## Moves the active tetramino down and draws the board
func go_down() -> void:
	game.go_down()
	draw_board()

## On line broken callback - dreaws the score and lines broken
func on_line_broken() -> void:
	draw_score()
	draw_linesBroken()

## Writes the score in [member TetrisControl.score_label]
func draw_score() -> void:
	score_label.text = "Score\n%07d" % game.score

## Writes broken line count in [member TetrisControl.lines_label]
func draw_linesBroken() -> void:
	lines_label.text = "Lines\n%07d" % game.lines_broken

## Writes placed piece count in [member TetrisControl.placed_label]
func draw_piecesPlaced() -> void:
	placed_label.text = "Placed\n%07d" % game.pieces_placed
	
## Game clock callback from [member TetrisControl._timer]
func timout_callback() -> void:
	game.go_down();
	draw_board()
	
## Callback from [signal Tetris._game_over] that stops the game
func on_game_over() -> void:
	_game_over = true
	_timer.stop()
	_timer_input.stop()

## Draws the game state from [member TetrisControl.game] 
## to [member TetrisControl.board_layer]
func draw_board() -> void:
	# Write the active tetramino and its shadow to the field 
	var field := game.field.duplicate(true)
	if game.figure != null:
		for row in range(4):
			for col in range(4):
				# Write active tetramino shadow
				var shadow := game.get_shadow()
				if row * 4 + col in shadow.image():
					field[row + shadow.y][col + shadow.x] = shadow.color
				# Write active tetramino
				if row * 4 + col in game.figure.image():
					field[row + game.figure.y][col + game.figure.x] = game.figure.color
				
	
	# Display the field
	board_layer.clear()
	for row in range(game.height):
		for col in range(game.width):
			if field[row][col] > 0:
				board_layer.set_cell(Vector2i(col, row), 0, Vector2i(field[row][col] - 1, 0))


## Callback to update next piece preview [member TetrisControl.preview_layer]
func on_draw_next_piece() -> void:
	draw_piecesPlaced()
	preview_layer.clear()
	draw_tetramino(game.next_figure, preview_layer)

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
			game.rotate(); update = true
		elif event.is_action("ui_left"):
			game.go_side(-1); update = true
		elif event.is_action("ui_right"):
			game.go_side(1); update = true
		elif event.is_action("ui_accept"):
			game.go_space(); update = true
		
		if update:
			draw_board()
