# MusicManager.gd
extends Node

@onready var music_player = $AudioStreamPlayer2D

func play_music(stream = null):
	music_player.stream = stream
	music_player.volume_db = 0
	music_player.play()

func fade_out_music(duration = 5.0):
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, duration)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	return tween  # so you can await finished if needed

func stop_music():
	music_player.stop()
