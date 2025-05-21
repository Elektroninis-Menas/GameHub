extends HBoxContainer
## Guess game input for inputing a word in single letter [class LineEdit] inputs 
class_name GuessInput

var inputs: Array[LineEdit]
var length: int

func _init(_length: int = 5) -> void:
	length = _length
	for i in range(length):
		var input := LineEdit.new()
		input.alignment = HORIZONTAL_ALIGNMENT_CENTER
		input.max_length = 1
		input.custom_minimum_size = Vector2(50, 50)
		inputs.append(input)

func _ready() -> void:
	for i: int in length:
		add_child(inputs[i])
		inputs[i].text_change_rejected.connect(func (rejected_substring: String):
			if i+1 < length:
				inputs[i+1].text = rejected_substring.capitalize()
				inputs[i+1].grab_focus()
				inputs[i+1].caret_column = 1
			)
		inputs[i].text_changed.connect(func (new_text: String):
			inputs[i].text = new_text.capitalize()
			if len(new_text) == 1:
				inputs[i].caret_column = 1
			if i != 0 and len(new_text) == 0:
				inputs[i-1].grab_focus()
			)
	inputs[0].grab_focus()
	
func get_word() -> String:
	var word : String = ""
	for letter in inputs:
		word += letter.text
	return word.strip_edges()
	
func set_letter_color(index: int, color: Color) -> void:
	var style = inputs[index].get_theme_stylebox("normal").duplicate(true)
	style.bg_color = color
	inputs[index].add_theme_stylebox_override("read_only", style)
	inputs[index].editable = false
