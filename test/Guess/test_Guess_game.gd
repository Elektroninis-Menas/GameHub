extends GutTest

var game: Control

func before_each():
	game = autoqfree(load("res://Scenes/GuessingGame/game.gd").new())

func test_load_word_list_returns_array():
	var result = game.load_word_list()
	assert_typeof(result, TYPE_ARRAY, "Should return an array")


func test_load_word_list_contains_strings():
	var result = game.load_word_list()
	if result.size() > 0:
		assert_typeof(result[0], TYPE_STRING, "Array elements should be strings")

func test_load_word_list_filters_correctly():
	var result = game.load_word_list()
	assert_false(result.is_empty(), "Word list should not be empty")
	
	for word in result:
		assert_eq(word.length(), 5, "All words should be 5 characters long")
		assert_eq(word.strip_edges(), word, "Words shouldn't have leading/trailing whitespace")
		assert_false(word.is_empty(), "Words shouldn't be empty strings")
		assert_true(word.is_valid_filename(), "Words should contain only alphabetic characters")

func test_word_list_path_is_correct():
	assert_eq(game.WORDS, "res://Scenes/GuessingGame/a_words.txt", "Word list path should be correct");
	
func test_file_access_success():
	var file = FileAccess.open(game.WORDS, FileAccess.READ)
	assert_not_null(file,"Should be able to open word list file")
	if file:
		file.close()
		
func test_word_list_no_duplicates():
	var result=game.load_word_list()
	var unique_words=[]
	for word in result:
		assert_false(unique_words.has(word),"Word list should not contain duplicates")
		unique_words.append(word)

func test_random_word_changes():
	game._ready()
	var first_word = game.random_word
	game._ready()
	var second_word = game.random_word
	assert_ne(first_word, second_word, "random word should change between calls (may rarely fail)")

func test_repeated_loading_consistency():
	var first_load = game.load_word_list()
	var second_load = game.load_word_list()
	assert_eq(first_load, second_load, "Repeated loads should return same words")
	
func test_word_list_contains_only_letters():
	var result = game.load_word_list()
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z]+$")  
	
	for word in result:
		assert_true(regex.search(word) != null, 
			"Word '%s' contains non-alphabetic characters" % word)
