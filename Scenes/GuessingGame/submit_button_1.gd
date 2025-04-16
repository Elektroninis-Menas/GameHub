extends Button

@export var start_index: int
@export var end_index: int

var logic := submitButton.new()

func _ready():
	logic.load_word_list()

func _on_pressed():
	var was_valid = logic.collect_word(start_index, end_index, get_parent())
	if was_valid:
		hide()
