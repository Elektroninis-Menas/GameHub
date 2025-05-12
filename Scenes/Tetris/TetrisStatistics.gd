## Class for loading and saving tetris game statistics
class_name TetrisStatistics

## Path to the statistcs json file
static var STATISTICS_JSON = "user://TetrisStatistics.json"

## Loads a Tetris statistics from [member STATISTICS_JSON] and returns a [Array] of data
static func load_statistics() -> Array:
	if !FileAccess.file_exists(STATISTICS_JSON):
		printerr("Tetris statistics file %s does not exist." % STATISTICS_JSON)
		return []
	
	var stat_file := FileAccess.open(STATISTICS_JSON, FileAccess.READ)
	if stat_file == null:
		printerr("Tetris statistics file found but cannot open.")
		return []
	
	var content = stat_file.get_as_text().strip_edges()
	stat_file.close()
	
	var data = JSON.parse_string(content)
	if data == null:
		printerr("Tetris statistics data could not parse into JSON")
		return []
		
	return data["Data"]

## Saves Tetris game [member stats] to config in [member config_path]
static func save_statistic(stats: Dictionary) -> void:
	var stat_file : FileAccess
	if FileAccess.file_exists(STATISTICS_JSON):
		stat_file = FileAccess.open(STATISTICS_JSON, FileAccess.READ_WRITE)
	else:
		stat_file = FileAccess.open(STATISTICS_JSON, FileAccess.WRITE_READ)
	
	if stat_file == null:
		printerr("Tetris statistics file found but cannot open.")
		return
	
	var data: Dictionary = {"Data" = []}
	var content = stat_file.get_as_text().strip_edges()
	if !content.is_empty():
		data = JSON.parse_string(content)
		if data == null:
			printerr("Tetris statistics data could not parse into JSON")
			return
		
	data["Data"].append(stats)
	var json_string := JSON.stringify(data, "  ")
	stat_file.store_string(json_string)
	stat_file.close()
	
