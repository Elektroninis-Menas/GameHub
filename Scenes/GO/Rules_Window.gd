extends Window

func _ready():
	hide()
	connect("close_requested", Callable(self, "_on_close_requested"))
	MusicManager.play_music_for_game("GO")

func _on_close_requested():
	hide()
