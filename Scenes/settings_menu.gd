extends Control

const SETTINGS_FILE = "user://settings.json"

@onready var volume: HSlider = $Volume  # Assigns the volume slider
@onready var mute: CheckBox = $Mute  # Assigns the mute checkbox

func _ready():
	# Load saved settings
	var settings = load_settings()
	var saved_volume = settings["volume"]
	var is_muted = settings["muted"]

	# Apply saved volume and mute state
	volume.value = float(saved_volume)
	mute.button_pressed = is_muted
	set_volume(saved_volume)

	AudioServer.set_bus_mute(0, is_muted)  # Apply mute state
	volume.editable = not is_muted  # Disable slider if muted

func _on_volume_value_changed(value: float) -> void:
	set_volume(value)
	save_settings(value, mute.button_pressed)  # Save both volume & mute state

	# Auto-toggle mute if volume is 0
	if value == 0:
		mute.button_pressed = true
	else:
		mute.button_pressed = false
	save_settings(value, mute.button_pressed)

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)  # Mute/unmute audio
	volume.editable = not toggled_on  # Disable slider if muted
	save_settings(volume.value, toggled_on)  # Save both volume & mute state

func set_volume(value: float):
	if value == 0:
		AudioServer.set_bus_mute(0, true)  # Mute if slider is at 0
	else:
		AudioServer.set_bus_mute(0, false)
		var volume_db = linear_to_db(value / 100.0)  # Convert 0-100 to dB
		AudioServer.set_bus_volume_db(0, volume_db)

func save_settings(volume_value: float, mute_state: bool):
	var data = {"volume": volume_value, "muted": mute_state}
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_FILE):
		return {"volume": 50, "muted": false}  # Default values
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if data and "volume" in data and "muted" in data:
		return data
	return {"volume": 50, "muted": false}  # Default values if file is empty/corrupt
