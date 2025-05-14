
extends Control

const WORDS = "res://Scenes/GuessingGame/a_words.txt"

var word_list: Array[String]
var random_word: String


func _ready():
	word_list = load_word_list()

	if word_list.is_empty():
		push_warning("Random word list is empty.")
		return

	random_word = word_list.pick_random()
	print("Random word:", random_word)


func load_word_list() -> Array[String]:
	var valid: Array[String]
	var file = FileAccess.open(WORDS, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var word = file.get_line().strip_edges().to_upper()
			if word.length() == 5:  # or any other check
				valid.append(word)
		file.close()
		print("Loaded", valid.size(), "words.")
	else:
		push_error("Failed to load word list.")
	
	return valid
