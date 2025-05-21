## Class for storing the state of a Tetramino piece
class_name Figure

## Tetramino type
enum TetraminoType {I, T, L, J, O, S, Z}

## Tetramino x positon
var x := 0 
## Tetramino y position
var y := 0
## Type of piece
var type: TetraminoType
## Piece rotation
var rotation: int
## Ann array of Tetraminos and their rotations
const figures : Array[Array] = [
	[[1, 5, 9, 13], [4, 5, 6, 7]], # I
	[[1, 4, 5, 6], [1, 4, 5, 9], [4, 5, 6, 9], [1, 5, 6, 9]], # T
	[[1, 2, 6, 10], [5, 6, 7, 9], [2, 6, 10, 11], [3, 5, 6, 7]], # L
	[[1, 2, 5, 9], [0, 4, 5, 6], [1, 5, 9, 8], [4, 5, 6, 10]], # J
	[[1, 2, 5, 6]], # O
	[[6, 7, 9, 10], [1, 5, 6, 10]], # S
	[[4, 5, 9, 10], [2, 6, 5, 9]], # Z
]

## Creates a new random type Tetramino 
func _init() -> void:
	x = 0
	y = 0
	type = randi_range(0, len(figures) - 1)
	rotation = 0

## Returns an Array indicies occupied by this tetramino in a 4x4 area.[br]
## Same as [code]figures[type][rotation][/code] 
func image() -> Array:
	return figures[type][rotation]

## Changes [member rotation] of this Tetramino
func rotate() -> void:
	rotation = (rotation + 1) % len(figures[type])

## String reprezentation of the current Tetramino
func _to_string() -> String:
	return "%s r:%d x:%d y:%d" % [
		TetraminoType.find_key(type), rotation, x, y
	]
