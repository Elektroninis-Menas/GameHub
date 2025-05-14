extends Button

@export_file("*.tscn") var game_scene: String

var scene: PackedScene


func _ready() -> void:
	if game_scene.is_empty():
		printerr('No scene given to button "%s"' % self.text)
		return


func _on_pressed() -> void:
	GameDifficulty.difficulty = 3
	scene = load(game_scene)
	print('Pressed "%s" button!' % self.text)
	if scene != null:
		var error: Error = get_tree().change_scene_to_packed(scene)
		if error != OK:
			printerr(error)
