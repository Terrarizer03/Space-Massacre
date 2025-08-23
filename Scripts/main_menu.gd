extends Control

var menuMusic = preload("res://Assets/Sound/Boss Battle 6 V1.wav")

@onready var TitleCard = $MainButtons/SpaceMassacre
@onready var FadeIn = $CanvasLayer/FadeIn
@onready var Credits = $Credits

func _ready() -> void:
	get_tree().paused = false
	
	MusicManager.play_music(-5, menuMusic)
	
	FadeIn.self_modulate.a = 1.0
	
	fade_out(0.75)

func _on_play_button_down() -> void:
	fade_in(2.0)
	MusicManager.fade_out_music(2.0)
	await get_tree().create_timer(2.15).timeout
	MusicManager.stop_music()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")

func fade_out(duration) -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(FadeIn, "self_modulate:a", 0.0, duration)
	fade_tween.set_trans(Tween.TRANS_BACK)
	fade_tween.set_ease(Tween.EASE_IN)

func _on_credits_button_down() -> void:
	Credits.show()

func _on_exit_button_down() -> void:
	fade_in(2.0)
	MusicManager.fade_out_music(2.0)
	await get_tree().create_timer(2.15).timeout
	MusicManager.stop_music()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
	
func _on_back_button_down() -> void:
	Credits.hide()

func fade_in(duration) -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(FadeIn, "self_modulate:a", 1.0, duration)
	fade_tween.set_trans(Tween.TRANS_BACK)
	fade_tween.set_ease(Tween.EASE_IN)
