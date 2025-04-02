extends Window

func _ready():
	hide()
	connect("close_requested", Callable(self, "_on_close_requested"))

func _on_close_requested():
	hide()
