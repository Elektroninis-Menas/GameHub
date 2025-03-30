extends Button

@export_file("*.tscn") var game_scene: String

func _on_pressed() -> void:
	if game_scene:
		get_tree().change_scene_to_file(game_scene)  # Load the main menu scene
	else:
		push_error("No scene assigned to 'game_scene' export variable!")
