extends ColorRect

func _ready() -> void:
	Global.disable_default_menu = false
	MusicManager.play_main_menu_music()
