extends ColorRect
@onready var game: TetrisControl = $"../Game"
@onready var statistics: ColorRect = $"../Statistics"
@onready var play_button: Button = $VBoxContainer/VBoxContainer/Play
@onready var statistics_button: Button = $VBoxContainer/VBoxContainer/Statistics

func _ready() -> void:
	play_button.pressed.connect(on_play_pressed)
	statistics_button.pressed.connect(on_statistics_pressed)
	show()

func on_play_pressed() -> void:
	game.start_game()
	hide_menu()

func show_menu() -> void:
	game.pause_game(true)
	show()

func hide_menu() -> void:
	game.pause_game(false)
	hide()

func on_statistics_pressed() -> void:
	hide()
	statistics.display_statistics()
