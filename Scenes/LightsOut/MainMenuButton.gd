extends Button

@export_file("*.tscn") var game_scene: String
var scene: PackedScene
@onready var rules_menu: PopupPanel = $"../RulesMenu"
@onready var rules_text: RichTextLabel = $"../RulesMenu/RulesText"
@onready var label: Label = $"../Label"
@onready var easy: Button = $"../ColorRect/Easy"
@onready var medium: Button = $"../ColorRect/Medium"
@onready var difficult: Button = $"../ColorRect/Difficult"
@onready var reset_menu: PopupPanel = $"../ResetMenu"
@onready var reset_button_confirm: Button = $"../ResetButtonConfirm"
@onready var reset_text: RichTextLabel = $"../ResetMenu/ResetText"
@onready var rules_button: Button = $"../RulesButton"
@onready var main_menu_button: Button = $"."


var can_toggle: bool = true
var rule_toggle: bool =true


func _ready() -> void:
	if game_scene.is_empty():
		printerr('No scene given to button "%s"' % self.text)
		return
	scene = load(game_scene)
	MusicManager.play_music_for_game("LightsOut")
	
# Function for the button to transition to a new scene
func _on_pressed() -> void:
	print('Pressed "%s" button!' % self.text)
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


func _on_reset_scores_button_button_down() -> void:
	if rule_toggle:
		reset_menu.visible = !reset_menu.visible
		rule_toggle = false
		get_tree().create_timer(0.5).timeout.connect(func(): rule_toggle = true)


func _on_reset_menu_visibility_changed() -> void:
	reset_text.visible = !reset_text.visible
	reset_button_confirm.visible = !reset_button_confirm.visible
	label.visible = !label.visible
	easy.visible = !easy.visible
	medium.visible = !medium.visible
	difficult.visible = !difficult.visible
	rules_button.visible = !rules_button.visible
	main_menu_button.visible = !main_menu_button.visible

func _on_reset_button_confirm_button_down() -> void:
	DirAccess.remove_absolute("user://high_scores.json")
	print("Save data Deleted")
