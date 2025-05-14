extends Node

var settings_menu_scene = preload("res://Scenes/Settings Menu.tscn")  # Change path
var settings_instance = null


func _input(event):
	if event.is_action_pressed("ui_cancel"):  # "Esc" toggles settings
		toggle_settings_menu()


func toggle_settings_menu():
	if settings_instance:
		settings_instance.queue_free()
		settings_instance = null
	else:
		settings_instance = settings_menu_scene.instantiate()
		get_tree().root.add_child(settings_instance)  # Add to root to overlay on all scenes
		settings_instance.set_as_top_level(true)  # Prevents scaling issues
