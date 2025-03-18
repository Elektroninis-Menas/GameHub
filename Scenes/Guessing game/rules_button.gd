extends Button

@onready var popup = get_node("VBoxContainer/Popup/PopupPanel")

func _ready():
	self.pressed.connect(_on_rules_pressed)

func _on_rules_pressed():
	print("Rules button clicked")
	popup.popup_centered()
