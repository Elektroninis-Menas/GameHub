extends Button

@onready var pause_menu: ColorRect = $"../../../PauseMenu"


func _pressed() -> void:
	pause_menu.show_menu()
