extends Button


func _ready() -> void:
	self.pressed.connect(_on_leave_pressed)


func _on_leave_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GO/Go_Menu.tscn")
