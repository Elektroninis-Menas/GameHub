extends Button

@export var popup_panel: NodePath  # Assign the PopupPanel in the Inspector


func _ready():
	connect("pressed", Callable(self, "_on_close_button_pressed"))


func _pressed() -> void:
	var panel = get_node(popup_panel)
	if panel:
		panel.visible = false  # Hide the popup panel
	else:
		push_error("PopupPanel node not found! Make sure it's assigned in the Inspector.")
