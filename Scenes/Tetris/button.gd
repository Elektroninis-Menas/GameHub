extends Button

@onready var menu: ColorRect = $"../../../Menu"

func _pressed() -> void:
	menu.show_menu()
