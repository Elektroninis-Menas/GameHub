extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GO/New_Game_Scene/New_Game_Scene.tscn")

func _on_rules_pressed() -> void:
	$"../Window".popup_centered()


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main menu/Main menu.tscn")
