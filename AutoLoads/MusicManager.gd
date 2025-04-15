extends Node

var music_player: AudioStreamPlayer

const SETTINGS_FILE = "user://settings.json"
const DEFAULT_VOLUME := 50.0
const DEFAULT_MUTED := false

func _ready():
	# Create and configure music player
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
		music_player.stream = preload("res://Sounds/BG.mp3")
		music_player.volume_db = -10
		music_player.finished.connect(_on_music_finished)
		music_player.play()

	# 🔊 Load and apply saved audio settings on startup
	var settings = load_settings()
	update_audio_settings(settings["volume"], settings["muted"])

func _on_music_finished():
	music_player.play()

func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stop()
		music_player.stream = stream
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
