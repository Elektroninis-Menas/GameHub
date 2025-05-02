extends ColorRect
@onready var tetris_control: TetrisControl = $"../Game"
@onready var resume_button: Button = $VBoxContainer/VBoxContainer/Resume
@onready var end_game_button: Button = $"VBoxContainer/VBoxContainer/End Game"
@onready var menu: ColorRect = $"../Menu"

const STATISTICS_JSON = "user://TetrisStatistics.json"

func _ready() -> void:
	resume_button.pressed.connect(hide_menu)
	end_game_button.pressed.connect(on_end_game_pressed)
	hide()

func on_end_game_pressed() -> void:
	tetris_control.end_game()
	var stats := {
		"score" : tetris_control.game.score,
		"lines_broken" : tetris_control.game.lines_broken,
		"pieces_placed" : tetris_control.game.pieces_placed,
		"time_played" : tetris_control.time_played,
		"date" : Time.get_datetime_string_from_system(false, true)}
	
	TetrisStatistics.save_statistic(stats, STATISTICS_JSON)
	hide()
	menu.show()

func show_menu() -> void:
	tetris_control.pause_game(true)
	show()

func hide_menu() -> void:
	tetris_control.pause_game(false)
	hide()
