extends Button
const MENU_SCENE_PATH = "res://Scenes/Main menu/Main menu.tscn"  

func _ready():
	self.pressed.connect(_on_exit_to_menu_pressed)

func _on_exit_to_menu_pressed():
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
