class_name Figure

var x := 0 
var y := 0
var type: int
var color: int
var rotation: int
const figures : Array[Array] = [
	[[1, 5, 9, 13], [4, 5, 6, 7]],
	[[4, 5, 9, 10], [2, 6, 5, 9]],
	[[6, 7, 9, 10], [1, 5, 6, 10]],
	[[1, 2, 5, 9], [0, 4, 5, 6], [1, 5, 9, 8], [4, 5, 6, 10]],
	[[1, 2, 6, 10], [5, 6, 7, 9], [2, 6, 10, 11], [3, 5, 6, 7]],
	[[1, 4, 5, 6], [1, 4, 5, 9], [4, 5, 6, 9], [1, 5, 6, 9]],
	[[1, 2, 5, 6]],
]

func _init(new_x: int, new_y: int) -> void:
	x = new_x
	y = new_y
	type = randi_range(0, len(figures) - 1)
	color = randi_range(1, 7)
	rotation = 0

func image() -> Array:
	return figures[type][rotation]

func rotate() -> void:
	rotation = (rotation + 1) % len(figures[type])
