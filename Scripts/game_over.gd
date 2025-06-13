extends Control

# Node references
@onready var main_scene = $"../../"
@onready var visible_ui = $Panel
@onready var Player = $"../../Player"

func _ready() -> void:
	# Allow this UI to process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
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
