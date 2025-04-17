extends Control
@onready var layers: Control = $Layers
@onready var board_layer: TileMapLayer = $Layers/Board/board
@onready var preview_layer: TileMapLayer = $"Layers/Side Panel/Preview/preview"
@onready var score_label: Label = $"Layers/Side Panel/Score/Label"
@onready var lines_label: Label = $"Layers/Side Panel/Lines/Label"
@onready var placed_label: Label = $"Layers/Side Panel/Placed/Label"

var game : Tetris
var game_over : bool = false
var timer : Timer
var timer_input : Timer
const TILE_SIZE := 30
const WIDTH = 10
const HEIGHT = 20

var _is_paused : bool = false

func _ready() -> void:
	#layers.position.x = DisplayServer.window_get_size().x / 2 - TILE_SIZE * WIDTH / 2
	#layers.position.y = TILE_SIZE
	game = Tetris.new(HEIGHT, WIDTH)
	game.game_over.connect(on_game_over)
	game.preview_figure.connect(on_draw_next_piece)
	game.on_line_broken.connect(on_line_broken)
	game.new_figure()
	draw_board()
	draw_score()
	draw_linesBroken()
	
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 1
	timer.timeout.connect(timout_callback)
	add_child(timer)
	
	timer_input = Timer.new()
	timer_input.wait_time = 0.1
	timer_input.autostart = true
	timer_input.timeout.connect(go_down) 

## Pauses the game if paused is true
func pause_game(paused: bool) -> void:
	timer.paused = paused
	timer_input.paused = paused
	_is_paused = paused
	

func go_down() -> void:
	game.go_down()
	board_layer.clear()
	draw_board()

func on_line_broken() -> void:
	draw_score()
	draw_linesBroken()

func draw_score() -> void:
	score_label.text = "Score\n%07d" % game.score

func draw_linesBroken() -> void:
	lines_label.text = "Lines\n%07d" % game.lines_broken

func draw_piecesPlaced() -> void:
	placed_label.text = "Placed\n%07d" % game.pieces_placed
	
func timout_callback() -> void:
	game.go_down();
	board_layer.clear()
	draw_board()
	
func on_game_over() -> void:
	game_over = true
	timer.stop()
	timer_input.stop()

func draw_board() -> void:
	var field = game.field.duplicate(true)
	
	if game.figure != null:
		for row in range(4):
			for col in range(4):
				if row * 4 + col in game.figure.image():
					field[row + game.figure.y][col + game.figure.x] = game.figure.color
	
	# Draw the main Tetris grid
	for row in range(game.height):
		for col in range(game.width):
			if field[row][col] > 0:
				board_layer.set_cell(Vector2i(col, row), 0, Vector2i(field[row][col] - 1, 0))

func on_draw_next_piece() -> void:
	draw_piecesPlaced()
	preview_layer.clear()
	if game.next_figure != null:
		for row in range(4):
			for col in range(4):
				if row * 4 + col in game.next_figure.image():
					preview_layer.set_cell(Vector2i(col, row + 1), 0, Vector2i(game.next_figure.color - 1, 0))



func _input(event: InputEvent) -> void:
	if game_over || _is_paused:
		return
	var update := false
	if Input.is_action_just_pressed("ui_down"):
		timer.stop()
		go_down()
		add_child(timer_input)
	if Input.is_action_just_released("ui_down"):
		timer.start()
		remove_child(timer_input)
		
	if event.is_pressed():
		if event.is_action("ui_up"):
			game.rotate(); update = true
		#elif event.is_action("ui_down"):
			#game.go_down(); update = true
		elif event.is_action("ui_left"):
			game.go_side(-1); update = true
		elif event.is_action("ui_right"):
			game.go_side(1); update = true
		elif event.is_action("ui_accept"):
			game.go_space(); update = true
		
		if update:
			board_layer.clear()
			draw_board()
