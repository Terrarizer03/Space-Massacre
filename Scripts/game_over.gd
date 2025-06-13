extends Control

# Node references
@onready var main_scene = $"../../"
@onready var visible_ui = $Panel
@onready var Player = $"../../Player"
@onready var EndMessage = $Panel/EndMessage

func _ready() -> void:
	# Allow this UI to process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	EndMessage.self_modulate.a = 0.0
	visible_ui.modulate.a = 0.0
	visible_ui.hide()
	
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
	
	
	
