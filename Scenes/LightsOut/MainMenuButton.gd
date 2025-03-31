extends Button

@export_file("*.tscn") var game_scene: String
var scene: PackedScene
@onready var rules_menu: PopupPanel = $"../RulesMenu"
@onready var rules_text: RichTextLabel = $"../RulesMenu/RulesText"
@onready var label: Label = $"../Label"
@onready var easy: Button = $"../ColorRect/Easy"
@onready var medium: Button = $"../ColorRect/Medium"
@onready var difficult: Button = $"../ColorRect/Difficult"

var can_toggle: bool = true

func _ready() -> void:
	if game_scene.is_empty():
		printerr("No scene given to button \"%s\"" % self.text)
		return
	scene = load(game_scene)
	
# Function for the button to transition to a new scene
func _on_pressed() -> void:
	print("Pressed \"%s\" button!" % self.text)
	if scene != null:
		var error: Error = get_tree().change_scene_to_packed(scene)
		if error != OK:
			printerr(error)

func _on_rules_button_button_down() -> void:
	if can_toggle:
		rules_menu.visible = !rules_menu.visible
		can_toggle = false
		get_tree().create_timer(0.5).timeout.connect(func(): can_toggle = true)

func _on_rules_menu_visibility_changed() -> void:
	rules_text.visible = !rules_text.visible
	label.visible = !label.visible
	easy.visible = !easy.visible
	medium.visible = !medium.visible
	difficult.visible = !difficult.visible
