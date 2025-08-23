extends Control

# Signals
signal resetRequested
signal endMusic

# Node references
@onready var main_scene = $"../../"
@onready var visible_ui = $Panel
@onready var Player = $"../../Player"
@onready var EndMessage = $Panel/EndMessage
@onready var FadeOutOverlay = $Panel/FadeOut

func _ready() -> void:
	# Allow this UI to process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	EndMessage.self_modulate.a = 0.0
	visible_ui.modulate.a = 0.0
	visible_ui.hide()
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	FadeOutOverlay.self_modulate.a = 0.0
	
	# Check if Player node exists before connecting
	if Player != null:
		Player.playerDeath.connect(_on_game_over)
	else:
		print("Error: Player node not found. Check the node path.")
		
	# Connect to the main scene's sendScore signal
	if main_scene != null:
		main_scene.sendScore.connect(_on_score_received)
	else:
		print("Error: MainScene not found. Check the node path.")

func _on_game_over():
	ending_message()
	visible_ui.show()
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(visible_ui, "modulate:a", 1.0, 1.0)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

func _on_score_received(final_score: int):
	# Update your game over UI with the final score
	# Assuming you have a Label node for displaying the score
	var score_label = $"Panel/Score"  # Adjust path as needed
	if score_label:
		score_label.text = "[center]Final Score: " + str(final_score) + "[/center]"
	print("Final Score: ", final_score)

func ending_message():
	var end_msg = ['"You didn’t escape… but you didn’t surrender either."', '"Your last breath was defiance."', '"Even surrounded, you made them earn every inch."', '"The silence welcomes you home."', '"Even a dying star shines."', '"The end was written. But you refused to read it."', '"You never stood a chance. But you stood anyway."']
	var random_msg = randi_range(0, len(end_msg) - 1)
	
	$Panel/EndMessage.text = "[center]" + end_msg[random_msg] + "[/center]"
	
	await get_tree().create_timer(1.15).timeout
	
	var tween = create_tween()
	tween.tween_property(EndMessage, "self_modulate:a", 1.0, 1.0)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(FadeOutOverlay, "self_modulate:a", 1.0, 2.5)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

func _on_restart_button_down() -> void:
	fade_out() # Fade out the screen before running
	endMusic.emit()
	
	await get_tree().create_timer(3.0).timeout
	
	resetRequested.emit()
	

func _on_main_menu_button_down() -> void:
	fade_out() # Fade out the screen before running
	endMusic.emit()
	
	await get_tree().create_timer(3.0).timeout
	
	get_tree().change_scene_to_file("res://Scenes/MenuScenes/MainMenu.tscn")
