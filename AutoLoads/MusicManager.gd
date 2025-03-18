extends Node

var music_player: AudioStreamPlayer

func _ready():
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
		music_player.stream = preload("res://Sounds/BG.mp3")  # Change to your MP3 file
		music_player.volume_db = -10  # Adjust volume
		music_player.finished.connect(_on_music_finished)  # Restart music when finished
		music_player.play()

func _on_music_finished():
	music_player.play()  # Restart manually when the track ends

func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stop()
		music_player.stream = stream
		music_player.play()
