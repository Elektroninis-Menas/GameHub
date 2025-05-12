extends Node

var default_settings_menu_scene = preload("res://Scenes/Settings Menu/Settings Menu.tscn")  # Change path
var settings_instance : Node

var disable_default_menu: bool = false

func _input(event):
	if disable_default_menu:
		return
	if event.is_action_pressed("ui_cancel"):  # "Esc" toggles settings
		toggle_settings_menu()
		
func toggle_settings_menu() -> void:
	if settings_instance:
		settings_instance.queue_free()
		settings_instance = null
	else:
		settings_instance = default_settings_menu_scene.instantiate()
		get_tree().root.add_child(settings_instance)  # Add to root to overlay on all scenes
		settings_instance.set_as_top_level(true)  # Prevents scaling issues
