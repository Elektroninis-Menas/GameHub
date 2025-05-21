extends GutTest

const A_WORDS_PATH = "res://Scenes/GuessingGame/words/a_words.txt"
const ALL_WORDS_PATH = "res://Scenes/GuessingGame/words"
var game: Control

func before_each():
	game = autoqfree(load("res://Scenes/GuessingGame/game.gd").new())
	var mock_button = autofree(Button.new())
	var mock_window = autofree(Window.new())
	game.win_window = mock_window
	game.submit_button = mock_button

func test_load_word_list_returns_array():
	var result = game.load_word_list(A_WORDS_PATH)
	assert_typeof(result, TYPE_ARRAY, "Should return an array")


func test_load_word_list_contains_strings():
	var result: Array[String] = game.load_word_list(A_WORDS_PATH)
	assert_typeof(result[0], TYPE_STRING, "Array elements should be strings")

func test_load_word_list_filters_correctly():
	var result = game.load_word_list(A_WORDS_PATH)
	assert_false(result.is_empty(), "Word list should not be empty")
	
	for word in result:
		assert_eq(word.length(), 5, "All words should be 5 characters long")
		assert_eq(word.strip_edges(), word, "Words shouldn't have leading/trailing whitespace")
		assert_false(word.is_empty(), "Words shouldn't be empty strings")
		assert_true(word.is_valid_filename(), "Words should contain only alphabetic characters")

func test_word_list_path_is_correct():
	assert_eq(game.WORDS_PATH, "res://Scenes/GuessingGame/words", "Word list path should be correct");
	
func test_file_access_success():
	var file = FileAccess.open(game.WORDS_PATH + "/a_words.txt", FileAccess.READ)
	assert_not_null(file,"Should be able to open word list file")
	if file:
		file.close()
		
func test_word_list_no_duplicates():
	var result: Array[String] = game.load_word_list(A_WORDS_PATH)
	var unique_words: Array[String] = []
	for word in result:
		assert_false(unique_words.has(word),"Word list should not contain duplicates")
		unique_words.append(word)
	
	
func test_repeated_loading_consistency():
	var first_load = game.load_word_list(A_WORDS_PATH)
	var second_load = game.load_word_list(A_WORDS_PATH)
	assert_eq(first_load, second_load, "Repeated loads should return same words")
	
func test_word_list_contains_only_letters():
	var result = game.load_word_list(A_WORDS_PATH)
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z]+$")  
	
	for word in result:
		assert_true(regex.search(word) != null, 
			"Word '%s' contains non-alphabetic characters" % word)
