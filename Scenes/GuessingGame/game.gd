extends Control

@export var win_window: Window
@export var result_label: Label
@export var attempts_label: Label
@export var guess_control: GuessControl
@export var submit_button: Button

const WORDS_PATH = "res://Scenes/GuessingGame/words"

var word_list: Array[String]
var target_word: String
var attempts_left := 5

func _ready():
	submit_button.pressed.connect(_on_submit_pressed)
	win_window.hide()
	word_list = load_word_list_from_folder(WORDS_PATH)

	if word_list.is_empty():
		push_warning("Word list is empty.")
		return

	target_word = word_list.pick_random()
	print("Target word: ", target_word)

## Loads a word list from [param folder_path]
static func load_word_list_from_folder(folder_path: String) -> Array[String]:
	var words: Array[String] = []
	var dir = DirAccess.open(folder_path)
	if not dir:
		push_error("Failed to open directory: " + folder_path)
		return words

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".txt"):
			var file_path = folder_path + "/" + file_name
			words.append_array(load_word_list(file_path))
		file_name = dir.get_next()
	dir.list_dir_end()
	
	print("Loaded ", words.size(), " words from folder ", folder_path)
	return words

## Loads a word list from [param file_path]
static func load_word_list(file_path: String) -> Array[String]:
	var valid: Array[String] = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var word = file.get_line().strip_edges().to_upper()
			if word.length() == 5:  # tavo patikra
				valid.append(word)
		file.close()
	else:
		push_error("Failed to load word list from: " + file_path)
	return valid

## Called when submit is pressed. Handles main game logic.
func _on_submit_pressed():
	var word := guess_control.get_last_word()
	
	if len(word) != len(target_word) or attempts_left == 0:
		return

	var letter_types: Array[GuessControl.LetterType] = check_guess(word, target_word)
	guess_control.color_last_word(letter_types)
	
	# If some letters are not good
	if letter_types.all(func(type: GuessControl.LetterType):
		return type == GuessControl.LetterType.GOOD):
			attempts_left = 0
			result_label.text = "Teisingai"
			win_window.title = "Atspėjai"
			win_window.show()
	else:
		attempts_left -= 1
		if attempts_left == 0:
			result_label.text = "Baigėsi bandymai!"
			win_window.title = "Neatspėjai"
			win_window.show()
		else:
			# Wrong guess so try again
			guess_control.add_word_input()
	
	attempts_label.text = "Bandymų liko: %s" % attempts_left

## returns an Array of [enum GuessControl.LetterType]
static func check_guess(guess: String, solution: String) -> Array[GuessControl.LetterType]:
	var rez : Array[GuessControl.LetterType]
	rez.resize(len(guess))
	rez.fill(GuessControl.LetterType.BAD)
	
	var used : Array[bool]
	used.resize(len(guess))
	used.fill(false)
	
	var right_guess_array := solution
	
	for i in range(5):
		var letter_type := GuessControl.LetterType.BAD
		var letter := guess[i]
		var letter_position := right_guess_array.find(letter)

		if letter_position != -1:
			if guess[i] == solution[i]:
				letter_type = GuessControl.LetterType.GOOD
			else:
				letter_type = GuessControl.LetterType.ALMOST
			right_guess_array[letter_position] = "#"  # Mark letter as used
		rez[i] = letter_type
		
	return rez

func reveal_hint() -> String:	
	var word = guess_control.get_last_entered_word()
	print(target_word + " " + word)
	for i in range(target_word.length()):
		if target_word[i] == word[i]:
			print(target_word[i] + " " + word[i])
			pass
		else:
			return "Raidė '{l}' yra {i} pozicijoje.".format({"l": target_word[i], "i": i+1})

	return "Daugiau patarimų nėra – visos raidės jau įrašytos teisingai."
