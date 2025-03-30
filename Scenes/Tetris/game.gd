extends Control
@onready var layers: Control = $Layers
@onready var board_layer: TileMapLayer = $Layers/board
@onready var preview_layer: TileMapLayer = $Layers/preview

var game : Tetris
var game_over : bool = false
var timer : Timer
const TILE_SIZE := 30
const WIDTH = 10
const HEIGHT = 20

func _ready() -> void:
	#layers.position.x = DisplayServer.window_get_size().x / 2 - TILE_SIZE * WIDTH / 2
	#layers.position.y = TILE_SIZE
	game = Tetris.new(HEIGHT, WIDTH)
	game.game_over.connect(on_game_over)
	game.preview_figure.connect(on_draw_next_piece)
	game.new_figure()
	draw_board()
	
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 1
	timer.timeout.connect(timout_callback)
	add_child(timer)

func timout_callback() -> void:
	game.go_down();
	board_layer.clear()
	draw_board()
	
func on_game_over() -> void:
	game_over = true
	timer.stop()

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
	preview_layer.clear()
	if game.next_figure != null:
		for row in range(4):
			for col in range(4):
				if row * 4 + col in game.next_figure.image():
					preview_layer.set_cell(Vector2i(col + WIDTH + 1, row), 0, Vector2i(game.next_figure.color - 1, 0))

func _input(event: InputEvent) -> void:
	var update := false
	if event.is_pressed() and !game_over:
		if event.is_action("ui_up"):
			game.rotate(); update = true
		elif event.is_action("ui_down"):
			game.go_down(); update = true
		elif event.is_action("ui_left"):
			game.go_side(-1); update = true
		elif event.is_action("ui_right"):
			game.go_side(1); update = true
		elif event.is_action("ui_accept"):
			game.go_space(); update = true
		
		if update:
			board_layer.clear()
			draw_board()
