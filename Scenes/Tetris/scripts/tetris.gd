## Tetris class that manages the game state
class_name Tetris

## Width of the game
var width := 10
## Height of the game
var height := 20
## Current game score
var score := 0
## Lines broken
var lines_broken := 0
## Pieces placed
var pieces_placed := 0
## Frozen in place tetraminos without [member figure].
var field: Array
## Curent active and falling tetramino copied from [member next_figure]
var figure : Figure
## Next to be [member figure]
var next_figure : Figure

## Signaled when game is over
signal game_over
## Signaled when next tetramino is generated
signal preview_figure
## Signaled when a line is broken
signal line_broken
## Signaled when a level changes every 10 lines broken. Passes [param level] as a singal argument.
signal level_change(level: int)

## Create a new Tetris game with dimensions [param new_height] and [param new_width]
func _init(new_height: int, new_width: int) -> void:
	score = 0
	lines_broken = 0
	pieces_placed = 0
	height = new_height
	width = new_width
	next_figure = Figure.new()
	for i in range(height):
		var new_line: Array[int]
		new_line.resize(width)
		field.append(new_line)

## Sets [member figure] to [member next_figure] and creates a new [member next_figure]. [br] 
## Incraments [member pieces_placed] and emits [signal preview_figure]. 
func new_figure() -> void:
	figure = next_figure
	next_figure = Figure.new()
	pieces_placed += 1
	preview_figure.emit()

## Checks weather [member figure] is intersecting with a block in [member field]
func intersects() -> bool:
	var intersection := false
	for row in range(4):
		for col in range(4):
			if row * 4 + col in figure.image():
				if row + figure.y >= height or col + figure.x >= width or col + figure.x < 0 or \
					field[row + figure.y][col + figure.x] > 0:
					intersection = true
	return intersection

## Breaks lines in [member field], updates the [member score] and emits [signal line_broken]
## and [signal level_change] when the level changed. 
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
	match lines:
		1: score +=   40 * (lines_broken/10 + 1)
		2: score +=  100 * (lines_broken/10 + 1)
		3: score +=  300 * (lines_broken/10 + 1)
		4: score += 1200 * (lines_broken/10 + 1)
	lines_broken += lines
	line_broken.emit()
	if lines_broken / 10 > (lines_broken - lines) / 10:
		level_change.emit(lines_broken/10)

## Drops [member figure] until an intersection accurs and updates 
## [member score] based on cells dropped * 2 
func go_space() -> void:
	while !intersects():
		figure.y += 1
		score += 2
	figure.y -= 1
	score -= 2
	freeze()

## Returns a new [class Figure] object that represents the shadow of [member figure]
func get_shadow() -> Figure:
	var old_y := figure.y
	while !intersects():
		figure.y += 1
	figure.y -= 1
	
	var shadow := Figure.new()
	shadow.x = figure.x
	shadow.y = figure.y
	figure.y = old_y
	shadow.type = figure.type
	shadow.rotation = figure.rotation
	return shadow

## Tries to move [member figure] down and friezes if an intersection accurs
func go_down() -> void:
	figure.y += 1
	if intersects():
		figure.y -= 1
		freeze()

## Updates the [member field] with [member figure], calls [method break_lines] and [method new_figure]. 
## If newly created figure is intersecting with the field, the signal [signal game_over] is emmited.
func freeze() -> void:
	for row in range(4):
		for col in range(4):
			if row * 4 + col in figure.image():
				field[figure.y + row][figure.x + col] = figure.type + 1
	
	break_lines()
	new_figure()
	figure.x = int(float(width) / 2) - 1
	if intersects():
		game_over.emit()

## Moves [member figure] on the x axis by [param dx] if no intersection accurs.
func go_side(dx: int) -> void:
	var old_x := figure.x
	figure.x += dx
	if intersects():
		figure.x = old_x

## Rotates [member figure] if no intersection accurs
func rotate() -> void:
	var old_rotation := figure.rotation
	figure.rotate()
	if intersects():
		figure.rotation = old_rotation

	
