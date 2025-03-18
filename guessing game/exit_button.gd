extends Button

@export_file("*.tscn") var menu_scene: String  # Assign the menu scene file in Inspector

func _ready():
	print("Button is ready!")

func _on_pressed() -> void:
	print("Returning to menu...")
	
	if menu_scene.is_empty():
		printerr("No menu scene assigned!")
		return

	var scene: PackedScene = load(menu_scene) as PackedScene
	if scene == null:
		printerr("Failed to load menu scene: %s" % menu_scene)
		return

	var error_code = get_tree().change_scene_to_packed(scene)
	if error_code != OK:
		printerr("Failed to change scene: Error code %d" % error_code)


func _on_rules_pressed() -> void:
	pass # Replace with function body.
