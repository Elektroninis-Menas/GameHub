extends ColorRect

@export var tetris_control: TetrisControl
@export var statistics: ColorRect
@export var play_button: Button
@export var statistics_button: Button

func _ready() -> void:
	play_button.pressed.connect(on_play_pressed)
	statistics_button.pressed.connect(on_statistics_pressed)
	show()

func on_play_pressed() -> void:
	tetris_control.start_game()
	hide_menu()

func show_menu() -> void:
	tetris_control.pause_game(true)
	show()

func hide_menu() -> void:
	tetris_control.pause_game(false)
	hide()

func on_statistics_pressed() -> void:
	hide()
	statistics.display_statistics()
