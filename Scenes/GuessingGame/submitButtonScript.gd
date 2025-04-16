extends Button

@export var start_index: int
@export var end_index: int

@onready var inputs: GridContainer = $"../GridContainer"
@onready var control: Control = $".."

func _on_pressed():
	var slice : Array = inputs.get_children().slice(start_index, end_index)
	var word := collect_word(slice)
	var target_word: String = control.random_word.to_upper()
	if target_word.is_empty():
		print("tuscia")
	else:
		print(target_word)
	
	collor_word(word, target_word, slice)
	
func collect_word(slice: Array) -> String:
	var word := ""
	
	for line_edit : LineEdit in slice:
		var letter = line_edit.text.strip_edges().to_upper()
		word += letter
	return word
	
func color_input(line_edit: LineEdit, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	line_edit.add_theme_stylebox_override("normal", style)

func collor_word(word, target_word, slice):
	if word in control.word_list:
		print("✅ Valid word!")
		#var guess_chars = []
		#var target_chars = []
		#for i in range(5):
			#guess_chars.append(word[i])
			#target_chars.append(target_word[i])
		var green_indices = []
		var used_target_indices = []
# 🟩 First pass – exact matches
		for i in range(5):
			if word[i] == target_word[i]:
				color_input(slice[i], Color(0, 1, 0))  # Green
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
				if word[i] == target_word[j]:
					color_input(slice[i], Color(1, 1, 0))  # Yellow
					used_target_indices.append(j)
					found_yellow = true
				break

			if not found_yellow:
				color_input(slice[i], Color(0.5, 0.5, 0.5))  # Gray
				print("Guess:", word)
				print("Target:", target_word)
				print("Green at:", green_indices)
				print("Used for yellow:", used_target_indices)
		return true
	else:
		print("❌ Not in word list.")
		return
	if word.length() < 5:
		print("Incomplete word!")
		return
