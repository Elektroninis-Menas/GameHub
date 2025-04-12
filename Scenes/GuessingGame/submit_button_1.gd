extends Button

var valid_words = []
var target_word = ""

func _ready():
	load_word_list()
	

func color_input(line_edit: LineEdit, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	line_edit.add_theme_stylebox_override("normal", style)

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
	var control_word = get_parent()
	target_word = control_word.random_word.to_upper()
	if target_word == "":
		print("tuscia")
	else:
		print(target_word)
	var word := ""
	var inputs := []
	for i in range(5):
		var line_edit = get_parent().get_node("GridContainer").get_child(i) as LineEdit
		var letter = line_edit.text.strip_edges().to_upper()
		word += letter
		inputs.append(line_edit)

	print("Collected word:", word)
	
	if is_valid_word(word):
		print("✅ Valid word!")
		# Proceed with game logic (check against solution, color letters, etc.)
	else:
		print("❌ Not in word list.")
	if word.length() < 5:
		print("Incomplete word!")
		return
		
	var guess_chars = []
	var target_chars = []
	for i in range(5):
		guess_chars.append(word[i])
		target_chars.append(target_word[i])

	var used_target_indices = []
	var green_indices = []

# 🟩 First pass – exact matches
	for i in range(5):
		if guess_chars[i] == target_chars[i]:
			color_input(inputs[i], Color(0, 1, 0))  # Green
			green_indices.append(i)
			used_target_indices.append(i)

# 🟨 Second pass – correct letter, wrong position
	for i in range(5):
		if i in green_indices:
			continue  # Already marked green

		var found_yellow = false
		for j in range(5):
			if j in used_target_indices:
				continue
			if guess_chars[i] == target_chars[j]:
				color_input(inputs[i], Color(1, 1, 0))  # Yellow
				used_target_indices.append(j)
				found_yellow = true
				break

		if not found_yellow:
			color_input(inputs[i], Color(0.5, 0.5, 0.5))  # Gray
	print("Guess:", guess_chars)
	print("Target:", target_chars)
	print("Green at:", green_indices)
	print("Used for yellow:", used_target_indices)
