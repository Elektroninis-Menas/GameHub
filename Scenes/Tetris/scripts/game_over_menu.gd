extends ColorRect

@export var play_again_button: Button
@export var exit_button: Button

@export var tetris_control: TetrisControl
@export var menu: ColorRect

func _ready() -> void:
	play_again_button.pressed.connect(on_play_again_pressed)
	exit_button.pressed.connect(on_exit_pressed)
	hide()

func on_play_again_pressed() -> void:
	tetris_control.restart_game()
	hide_menu()

func on_exit_pressed() -> void:
	hide()
	menu.show()

func show_menu() -> void:
	tetris_control.pause_game(true)
	show()

func hide_menu() -> void:
	tetris_control.pause_game(false)
	hide()
