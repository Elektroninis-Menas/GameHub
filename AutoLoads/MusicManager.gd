extends Node

var music_player: AudioStreamPlayer
var current_playlist: Array = []
var current_track_index: int = 0
var lights_out_tracks: Array = []
var game_tracks := {}  # Dictionary to cache music tracks per game
var current_mode := ""  # Can be "main_menu", "lights_out", etc.

const SETTINGS_FILE = "user://settings.json"
const DEFAULT_VOLUME := 50.0
const DEFAULT_MUTED := false

func _ready():
	# Create and configure music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = -10
	music_player.finished.connect(_on_music_finished)
	
	# Load Lights Out music tracks
	_load_lights_out_tracks()
	
	# Start with main menu music
	play_main_menu_music()

	# Load and apply saved audio settings
	var settings = load_settings()
	update_audio_settings(settings.get("volume", DEFAULT_VOLUME), 
						 settings.get("muted", DEFAULT_MUTED))

func _load_lights_out_tracks():
	var dir = DirAccess.open("res://Sounds/LightsOut/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".mp3"):
				var track = load("res://Sounds/LightsOut/" + file_name)
				if track:
					lights_out_tracks.append(track)
			file_name = dir.get_next()
	print("Loaded Lights Out tracks: ", lights_out_tracks.size())

func _on_music_finished():
	if current_playlist.size() > 0:
		play_next_track()

func play_main_menu_music():
	var main_menu_track = preload("res://Sounds/BG.mp3")
	if current_mode == "main_menu" and music_player.playing:
		return  # Already playing main menu music
	
	current_playlist = []
	music_player.stream = main_menu_track
	music_player.play()
	current_mode = "main_menu"

func play_music_for_game(game_name: String):
	var lower_name = game_name.to_lower()
	if current_mode == lower_name and music_player.playing:
		return  # Already playing this game's music
	
	if not game_tracks.has(lower_name):
		game_tracks[lower_name] = _load_music_from_folder("res://Sounds/" + game_name + "/")
	
	var tracks = game_tracks[lower_name]
	if tracks.size() == 0:
		print("No tracks found for game: ", game_name)
		return
	
	current_playlist = tracks.duplicate()
	current_playlist.shuffle()
	current_track_index = 0
	music_player.stream = current_playlist[current_track_index]
	music_player.play()
	current_mode = lower_name

func play_next_track():
	if current_playlist.size() == 0:
		return
	
	current_track_index = (current_track_index + 1) % current_playlist.size()
	music_player.stream = current_playlist[current_track_index]
	music_player.play()

func update_audio_settings(vol: float, is_muted: bool):
	AudioServer.set_bus_mute(0, is_muted)
	if not is_muted:
		var vol_db = linear_to_db(vol / 100.0)
		AudioServer.set_bus_volume_db(0, vol_db)

func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_FILE):
		return {"volume": DEFAULT_VOLUME, "muted": DEFAULT_MUTED}
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if not file:
		return {"volume": DEFAULT_VOLUME, "muted": DEFAULT_MUTED}
	
	var content = file.get_as_text().strip_edges()
	file.close()
	
	var data = JSON.parse_string(content)
	if not data or typeof(data) != TYPE_DICTIONARY:
		return {"volume": DEFAULT_VOLUME, "muted": DEFAULT_MUTED}
	
	return {
		"volume": clamp(float(data.get("volume", DEFAULT_VOLUME)), 0.0, 100.0),
		"muted": bool(data.get("muted", DEFAULT_MUTED))
	}
	
func set_volume(volume: float) -> void:
	volume = clamp(volume, 0.0, 100.0)
	var volume_db = linear_to_db(volume / 100.0)
	AudioServer.set_bus_volume_db(0, volume_db)
	save_volume(volume)
	
func set_save_mute(mute: bool) -> void:
	AudioServer.set_bus_mute(0, mute)
	save_mute(mute)
	
func save_volume(volume: float):
	var data: Dictionary
	var file: FileAccess
	if FileAccess.file_exists(SETTINGS_FILE):
		file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		data = JSON.parse_string(file.get_as_text().strip_edges())
		file.close()
	else:
		data = {}
	
	file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	data["volume"] = volume
	file.store_string(JSON.stringify(data))
	file.close()
	
func save_mute(mute: bool):
	var data: Dictionary
	var file: FileAccess
	if FileAccess.file_exists(SETTINGS_FILE):
		file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		data = JSON.parse_string(file.get_as_text().strip_edges())
		file.close()
	else:
		data = {}
	
	file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	data["muted"] = mute
	file.store_string(JSON.stringify(data))
	file.close()
	
func _load_music_from_folder(path: String) -> Array:
	var tracks := []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".mp3"):
				var track = load(path + file_name)
				if track:
					tracks.append(track)
			file_name = dir.get_next()
	dir.list_dir_end()
	print("Loaded ", tracks.size(), " tracks from: ", path)
	return tracks
