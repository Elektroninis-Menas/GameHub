extends Control

const SETTINGS_FILE = "user://settings.json"
const DEFAULT_VOLUME := 50.0
const DEFAULT_MUTED := false

@onready var volume: HSlider = $ColorRect/MarginContainer/VBoxContainer/Volume
@onready var mute: CheckBox = $ColorRect/MarginContainer/VBoxContainer/Mute

func _ready():
	# Load and apply settings
	var settings = load_settings()
	print("Loaded settings: ", settings)  # Debug
	
	volume.value = settings["volume"]
	mute.button_pressed = settings["muted"]
	
	# Force immediate audio update
	update_audio_settings(settings["volume"], settings["muted"])
	volume.editable = not settings["muted"]

func _on_volume_value_changed(value: float) -> void:
	value = clamp(value, 0.0, 100.0)
	mute.button_pressed = (value == 0)  # Auto-mute at zero volume
	update_audio_settings(value, mute.button_pressed)
	save_settings(value, mute.button_pressed)

func _on_mute_toggled(toggled_on: bool) -> void:
	volume.editable = not toggled_on
	update_audio_settings(volume.value, toggled_on)
	save_settings(volume.value, toggled_on)

func update_audio_settings(vol: float, is_muted: bool):
	AudioServer.set_bus_mute(0, is_muted)
	if not is_muted:
		var vol_db = linear_to_db(vol / 100.0)
		AudioServer.set_bus_volume_db(0, vol_db)
	print("Audio updated - Volume: ", vol, " dB | Muted: ", is_muted)  # Debug

func save_settings(vol: float, is_muted: bool):
	var data = {
		"volume": clamp(vol, 0.0, 100.0),
		"muted": is_muted
	}
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("Settings saved: ", data)  # Debug
	else:
		print("Error: Could not save settings!")  # Debug

func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_FILE):
		print("Note: No settings file found, using defaults.")
		return {"volume": DEFAULT_VOLUME, "muted": DEFAULT_MUTED}
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if not file:
		print("Warning: Could not open settings file, using defaults.")
		return {"volume": DEFAULT_VOLUME, "muted": DEFAULT_MUTED}
	
	var content = file.get_as_text().strip_edges()
	file.close()
	
	var data = JSON.parse_string(content)
	if not data or typeof(data) != TYPE_DICTIONARY:
		print("Error: Invalid JSON, using defaults.")
		return {"volume": DEFAULT_VOLUME, "muted": DEFAULT_MUTED}
	
	# Validate loaded data
	return {
		"volume": clamp(float(data.get("volume", DEFAULT_VOLUME)), 0.0, 100.0),
		"muted": bool(data.get("muted", DEFAULT_MUTED))
	}
