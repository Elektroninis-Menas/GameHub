extends VBoxContainer
## Guess game Control for handling all word inputs from [class GuessInput]
class_name GuessControl

## Active word letter inputs as [class GuessInput]
var word_control: GuessInput
var last: String= ""

## BAD - Letter is not in word [br]
## ALMOST - Letter is in wrong place [br]
## GOOD - Letter is in the right place
enum LetterType {BAD, ALMOST, GOOD}

func _ready() -> void:
	word_control = GuessInput.new(5)
	add_child(word_control)

## Gets the last inputed word
func get_last_word() -> String:
	last = word_control.get_word()
	return word_control.get_word()

## Adds a new [class GuessInput] and sets it as the active [member word_control]
func add_word_input(length: int = 5) -> void:
	word_control = GuessInput.new(length)
	add_child(word_control)
	
## Colors [member word_control] inputs based on given [param letter_types]
func color_last_word(letter_types: Array[LetterType]) -> void:
	for i in range(word_control.length):
		var color: Color
		match letter_types[i]:
			LetterType.BAD: 
				color = Color(0.3, 0.3, 0.3)	# Gray
			LetterType.ALMOST: 
				color = Color(0.9, 0.8, 0.2)	# Yellow
			LetterType.GOOD: 
				color = Color(0.2, 0.8, 0.2)	# Green
		
		word_control.set_letter_color(i, color)

func get_last_entered_word() -> String:
	return last
