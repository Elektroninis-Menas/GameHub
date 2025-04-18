class_name Tetris

var level := 2
var score := 0
var field: Array
var width := 10
var height := 20
var figure : Figure
var next_figure : Figure
var lines_broken := 0
var pieces_placed := -1

signal game_over
signal preview_figure
signal on_line_broken

func _init(new_height: int, new_width: int) -> void:
	height = new_height
	width = new_width
	next_figure = Figure.new(int(float(width) / 2) - 1, 0)
	for i in range(height):
		var new_line: Array[int]
		new_line.resize(width)
		field.append(new_line)

func new_figure() -> void:
	figure = next_figure
	next_figure = Figure.new(int(float(width) / 2) - 1, 0)
	pieces_placed += 1
	preview_figure.emit()

func intersects() -> bool:
	var intersection := false
	for row in range(4):
		for col in range(4):
			if row * 4 + col in figure.image():
				if row + figure.y >= height or col + figure.x >= width or col + figure.x < 0 or \
					field[row + figure.y][col + figure.x] > 0:
					intersection = true
	return intersection

func break_lines() -> void:
	var lines := 0
	for row in range(1, height):
		var zeros := 0
		for col in range(width):
			if field[row][col] == 0:
				zeros += 1
		if zeros == 0:
			lines += 1
			for row1 in range(row, 1, -1):
				for col in range(width):
					field[row1][col] = field[row1 - 1][col]
	score += lines ** 2
	lines_broken += lines
	on_line_broken.emit()
	
func go_space() -> void:
	while !intersects():
		figure.y += 1
	figure.y -= 1
	freeze()
	
func get_shadow() -> Figure:
	var initial_y := figure.y
	while !intersects():
		figure.y += 1
	figure.y -= 1
	
	
	var shadow := Figure.new(figure.x, figure.y)
	figure.y = initial_y
	shadow.type = figure.type
	shadow.rotation = figure.rotation
	shadow.color = Figure.MAX_COLORS + 1
	return shadow
	
func go_down() -> void:
	figure.y += 1
	if intersects():
		figure.y -= 1
		freeze()

func freeze() -> void:
	for row in range(4):
		for col in range(4):
			if row * 4 + col in figure.image():
				field[figure.y + row][figure.x + col] = figure.color
	
	break_lines()
	new_figure()
	if intersects():
		game_over.emit()

func go_side(dx: int) -> void:
	var old_x := figure.x
	figure.x += dx
	if intersects():
		figure.x = old_x

func rotate() -> void:
	var old_rotation := figure.rotation
	figure.rotate()
	if intersects():
		figure.rotation = old_rotation
