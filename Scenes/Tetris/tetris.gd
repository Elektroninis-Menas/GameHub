extends Control
@onready var tile_map: TileMapLayer = $TileMapLayer


const tetramino_indices: Dictionary[String, int] = {
	"L": 0, "J": 1, "I": 2, "S": 3, "Z": 4, "T": 5, "O": 6
}

func _ready() -> void:
	var tetraminos: Array[TileMapPattern]
	for tetramino: String in tetramino_indices:
		tetraminos.append(tile_map.tile_set.get_pattern(tetramino_indices[tetramino]))
	
	var pos: Vector2i = Vector2i(0, 0)
	# for tetramino: TileMapPattern in tetraminos:
	#	tile_map.set_pattern(pos, tetramino)
	#	pos.x += tetramino.get_size().x
		
