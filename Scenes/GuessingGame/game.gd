extends Control

var word_list = []
var random_word

func _ready():
	var file = FileAccess.open("res://Scenes/GuessingGame/a_words.txt", FileAccess.READ)
	while not file.eof_reached():
		var word = file.get_line().strip_edges()
		if word.length() > 0:
			word_list.append(word)
	file.close()

	random_word = word_list[randi() % word_list.size()]
	print("Random word:", random_word)
