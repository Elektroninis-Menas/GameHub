extends ColorRect

@export var resume_button: Button
@export var restart_button: Button
@export var exit_button: Button
@export var volume: HSlider
@export var mute: CheckBox

@export var tetris_control: TetrisControl
@export var menu: ColorRect

func _input(event):
	if event.is_action_pressed("ui_cancel") and !menu.visible:
		if visible:
			hide_menu()
		else:
			show_menu()

func _ready() -> void:
	Global.disable_default_menu = true
	var music_settings := MusicManager.load_settings()
	
	volume.value = music_settings["volume"]
	mute.button_pressed = music_settings["muted"]
	
	volume.value_changed.connect(MusicManager.set_volume)
	volume.drag_ended.connect(_save_volume)
	mute.toggled.connect(MusicManager.set_save_mute)
	
	resume_button.pressed.connect(hide_menu)
	restart_button.pressed.connect(on_restart_pressed)
	exit_button.pressed.connect(on_exit_pressed)
	hide()

func _save_volume(changed: bool) -> void:
	if changed:
		MusicManager.save_volume(volume.value)

func on_restart_pressed() -> void:
	tetris_control.restart_game()
	hide()

func on_exit_pressed() -> void:
	tetris_control.end_game()
	tetris_control.exit_game()
	
	hide()
	menu.show()

func show_menu() -> void:
	tetris_control.pause_game(true)
	show()

func hide_menu() -> void:
	tetris_control.pause_game(false)
	hide()
