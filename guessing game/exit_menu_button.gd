extends Button

@export var popup_panel: PopupPanel
@export var exit_menu_button: Button

func _on_pressed() -> void:
	if popup_panel:
		popup_panel.visible = false
	if exit_menu_button:
		exit_menu_button.visible = false
