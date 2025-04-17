extends ColorRect
@onready var game: Control = $"../Game"

func _ready() -> void:
	show_menu()

func _on_play_pressed() -> void:
	hide_menu()

func show_menu() -> void:
	game.pause_game(true)
	show()

func hide_menu() -> void:
	game.pause_game(false)
	hide()
