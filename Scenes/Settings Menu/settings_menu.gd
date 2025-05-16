extends Control

@onready var volume: HSlider = $PanelContainer/VBoxContainer/HBoxContainer/Volume
@onready var mute: CheckBox = $PanelContainer/VBoxContainer/HBoxContainer/Mute

func _input(event: InputEvent) -> void:
	event

func _ready() -> void:
	# Global.disable_default_menu = false
	var music_settings := MusicManager.load_settings()
	
	volume.value = music_settings["volume"]
	mute.button_pressed = music_settings["muted"]
	
	volume.value_changed.connect(MusicManager.set_volume)
	volume.drag_ended.connect(_save_volume)
	mute.toggled.connect(MusicManager.set_save_mute)

func _save_volume(changed: bool) -> void:
	if changed:
		MusicManager.save_volume(volume.value)
