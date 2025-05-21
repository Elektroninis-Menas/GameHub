extends ColorRect

@export var table: RichTextLabel
@export var back_button: Button
@export var menu: ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	hide()


func display_statistics() -> void:
	show()
	if !FileAccess.file_exists(TetrisStatistics.STATISTICS_JSON):
		table.text = "No data yet!"
		return

	var data := TetrisStatistics.load_statistics();
	if data.is_empty():
		table.text = "No data yet!"
		return

	var header: Array[String] = ["Score", "Lines broken", "Pieces placed", "Time played", "Date"]

	table.clear()
	table.push_table(len(header))
	for title: String in header:
		table.push_cell()
		table.append_text(title)
		table.pop()

	for dataLine: Dictionary in data:
		table.append_text("[cell][right]%.0f[/right][/cell]" % dataLine["score"])
		table.append_text("[cell][right]%.0f[/right][/cell]" % dataLine["lines_broken"])
		table.append_text("[cell][right]%.0f[/right][/cell]" % dataLine["pieces_placed"])
		table.append_text("[cell][right]%.0f[/right][/cell]" % dataLine["time_played"])
		table.append_text("[cell]%s[/cell]" % dataLine["date"])

	table.pop()


func _on_back_button_pressed() -> void:
	hide()
	menu.show()
