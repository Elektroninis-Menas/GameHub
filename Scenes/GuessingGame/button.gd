extends Button

var winwindow


func _ready():
	winwindow = get_parent()


func _on_pressed():
	winwindow.hide()
