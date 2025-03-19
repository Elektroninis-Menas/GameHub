extends Button

@export var popup_panel: NodePath
func _ready():
	connect("pressed", Callable(self, "_on_rules_button_pressed"))

func _pressed() -> void:
	var panel = get_node(popup_panel)
	if panel:
		panel.visible = true  # Show the popup panel
	else:
		push_error("PopupPanel node not found! Make sure it's assigned in the Inspector.")
