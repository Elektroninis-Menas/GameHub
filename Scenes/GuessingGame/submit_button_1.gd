extends Button

var valid_words = []

func _ready():
	load_word_list()

func load_word_list():
	var file = FileAccess.open("res://Scenes/GuessingGame/a_words.txt", FileAccess.READ)
	if file:
		while not file.eof_reached():
			var word = file.get_line().strip_edges().to_upper()
			if word.length() == 5: # or any other check
				valid_words.append(word)
		file.close()
		print("Loaded", valid_words.size(), "words.")
	else:
		push_error("Failed to load word list.")
			
func is_valid_word(word: String) -> bool:
	return word in valid_words
	
func _on_pressed() -> void:
	var word := ""
	for i in range(5):
		var line_edit = get_parent().get_node("GridContainer").get_child(i) as LineEdit
		word += line_edit.text.strip_edges().to_upper()
	if is_valid_word(word):
		print("✅ Valid word!")
		# Proceed with game logic (check against solution, color letters, etc.)
	else:
		print("❌ Not in word list.")
	if word.length() < 5:
		print("Incomplete word!")
		return
