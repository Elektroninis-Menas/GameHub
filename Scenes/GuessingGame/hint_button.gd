extends Button

@onready var hint_dialog: AcceptDialog = $AcceptDialog
@onready var hint_label: Label = $AcceptDialog/Label
@export var game: Node

var hint_used := false

func _on_pressed() -> void:
	if hint_used:
		hint_label.text = "Nebeturi patarimo."
		hint_dialog.popup_centered()
		return
	if game and game.has_method("reveal_hint"):
		hint_label.text = game.reveal_hint()
		hint_dialog.popup_centered()
		hint_used = true
	else:
		hint_label.text = "Nepavyko gauti patarimo."
		hint_dialog.popup_centered()
