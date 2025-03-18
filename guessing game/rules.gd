extends Button

@export var popup_panel: PopupPanel  # Assign the PopupPanel in the Inspector
@export var exit_menu_button: Button  # Assign the Exit Menu Button in the Inspector

func _on_pressed() -> void:
	if popup_panel:
		popup_panel.visible = !popup_panel.visible
		if exit_menu_button:
			exit_menu_button.visible = popup_panel.visible
		else:
			printerr("Exit Menu Button not assigned!")
	else:
		printerr("PopupPanel not assigned to the button!")
