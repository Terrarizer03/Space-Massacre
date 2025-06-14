extends Node2D

# INIT =============
# signal ------------
signal sendScore
signal cameraShake
signal waveEnd

# variables -------------
var wave = 0
var score = 0
var game_start = false
var spawning = true
var spawned_enemies = 0
var player_death = null

# preloads ------------
var dialogue_scene = preload("res://Dialogue/dialogue.tscn")
var circle_enemy = preload("res://Scenes/Enemies/CircleEnemy.tscn")
var triangle_enemy = preload("res://Scenes/Enemies/TriangleEnemy.tscn")
var square_enemy = preload("res://Scenes/Enemies/SquareEnemy.tscn")

# On Ready -------------
@onready var wave_indicator = $CanvasLayer/Control/WaveIndicator
@onready var score_indicator = $"CanvasLayer/Control/ScoreIndicator"
@onready var heartcontainer = $CanvasLayer/Control/HBoxContainer
@onready var Player = $Player
@onready var canvas = $CanvasLayer/Control
@onready var UpgradePanel = $CanvasLayer/UpgradePanel

func _ready() -> void:
	canvas.modulate.a = 0.0
	player_death = Player.playerDeath.connect(_end_game)

	# Connect to the upgrade panel's card selection signal
	UpgradePanel.cardSelected.connect(_on_upgrade_selected)

	# Connect upgrade signals to player
	UpgradePanel.strengthUpgrade.connect(Player._on_strength_upgrade)
	UpgradePanel.healthUpgrade.connect(Player._on_health_upgrade)
	UpgradePanel.speedUpgrade.connect(Player._on_speed_upgrade)
	UpgradePanel.attackSpeedUpgrade.connect(Player._on_attack_speed_upgrade)

	dialogueStart()
	
	Player.healthChanged.connect(_on_player_health_changed)

func spawn_circle_enemy():
	while true:
		if spawning:
			spawned_enemies += 1
			var spawnpos = determineSpawnPos()
			
			var circle_instance = circle_enemy.instantiate()
			circle_instance.position = spawnpos
			add_child(circle_instance)
			
			circle_instance.Enemydeath.connect(func(): scoreChange(10))
			
			await get_tree().create_timer(1).timeout
		else:
			await get_tree().create_timer(0.1).timeout

func spawn_triangle_enemy():
	while true:
		if spawning and wave >= 3:
			spawned_enemies += 1
			var spawnpos = determineTriangleSpawnPos()
			
			var triangle_instance = triangle_enemy.instantiate()
			triangle_instance.position = spawnpos
			add_child(triangle_instance)
			
			triangle_instance.Enemydeath.connect(func(): scoreChange(15))
			
			await get_tree().create_timer(5).timeout  # Spawn triangles less frequently
		else:
			await get_tree().create_timer(0.1).timeout

func spawn_square_enemy():
	while true:
		if spawning and wave >= 5:
			spawned_enemies += 1
			var spawnpos = determineSquareSpawnPos()
			
			var square_instance = square_enemy.instantiate()
			square_instance.position = spawnpos
			add_child(square_instance)
			
			square_instance.Enemydeath.connect(func(): scoreChange(25))
			
			await get_tree().create_timer(20).timeout
		else:
			await get_tree().create_timer(0.1).timeout

func wave_function():
	if wave >= 1:
		$WaveEndSound.play()
	
	wave += 1
	spawning = true
	spawned_enemies = 0
	
	wave_indicator.text = "Wave " + str(wave)
	score_indicator.text = "Score: " + str(score)
	
	# Spawn duration increases with wave number
	var spawn_duration = 8 + (wave * 2)  # 10s, 12s, 14s, etc.
	
	# Wait for spawn duration
	await get_tree().create_timer(spawn_duration).timeout
	spawning = false
	
	# Wait for all enemies to be defeated
	while get_tree().get_nodes_in_group("Enemy").size() > 0:
		await get_tree().process_frame
	
	print("WAVE ", wave, " ENDED - Enemies spawned: ", spawned_enemies)
	
	# Check if this is an odd wave number (1, 3, 5, etc.) to show upgrade panel
	if wave % 2 == 1:
		# Show upgrade panel and fade in
		UpgradePanel.show()
		
		# Fade in tween
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(UpgradePanel, "modulate:a", 1.0, 0.8)
		fade_in_tween.set_trans(Tween.TRANS_SINE)
		fade_in_tween.set_ease(Tween.EASE_IN_OUT)
		
		# Wait for fade in to complete, then spawn cards
		await fade_in_tween.finished
		UpgradePanel.spawnCards()
		
		# Wait for player to select an upgrade
		await UpgradePanel.cardSelected
		
		# Fade out tween
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(UpgradePanel, "modulate:a", 0.0, 0.8)
		fade_out_tween.set_trans(Tween.TRANS_SINE)
		fade_out_tween.set_ease(Tween.EASE_IN_OUT)
		
		# Wait for fade out to complete, then hide
		await fade_out_tween.finished
		UpgradePanel.hide()
		
		# Small delay after upgrade selection
		await get_tree().create_timer(1.0).timeout
	else:
		# Normal break duration between waves when no upgrade panel
		var break_duration = 5
		await get_tree().create_timer(break_duration).timeout
	
	# Start next wave
	wave_function()

func _on_upgrade_selected():
	# This function is called when a card is selected
	# You can add any additional logic here if needed
	print("Upgrade selected for wave ", wave)

func determineTriangleSpawnPos():
	var screen_width = 1152
	var screen_height = 648
	var margin = 50  # Keep 50 pixels away from edges
	
	# Random position within the play area (with margin)
	var spawn_pos = Vector2()
	spawn_pos.x = randf_range(margin, screen_width - margin)
	spawn_pos.y = randf_range(margin, screen_height - margin)
	
	return spawn_pos

func determineSpawnPos():
	var screen_width = 1152
	var screen_height = 648
	var spawn_margin = 50  # Distance outside screen bounds
	
	# Randomly choose which side to spawn from (0=left, 1=right, 2=top, 3=bottom)
	var side = randi() % 4
	var spawn_pos = Vector2()
	
	match side:
		0:  # Left side
			spawn_pos.x = -spawn_margin
			spawn_pos.y = randf() * screen_height
		1:  # Right side
			spawn_pos.x = screen_width + spawn_margin
			spawn_pos.y = randf() * screen_height
		2:  # Top side
			spawn_pos.x = randf() * screen_width
			spawn_pos.y = -spawn_margin
		3:  # Bottom side
			spawn_pos.x = randf() * screen_width
			spawn_pos.y = screen_height + spawn_margin
	
	return spawn_pos

func determineSquareSpawnPos():
	var screen_width = 1152
	var screen_height = 648
	var spawn_margin = 100  # Distance outside screen bounds
	
	# Randomly choose which side to spawn from (0=left, 1=right, 2=top, 3=bottom)
	var side = randi() % 4
	var spawn_pos = Vector2()
	
	match side:
		0:  # Left side
			spawn_pos.x = -spawn_margin
			spawn_pos.y = randf() * screen_height
		1:  # Right side
			spawn_pos.x = screen_width + spawn_margin
			spawn_pos.y = randf() * screen_height
		2:  # Top side
			spawn_pos.x = randf() * screen_width
			spawn_pos.y = -spawn_margin
		3:  # Bottom side
			spawn_pos.x = randf() * screen_width
			spawn_pos.y = screen_height + spawn_margin
	
	return spawn_pos

func dialogueStart():
	# Instantiate and show dialogue
	var dialogue_instance = dialogue_scene.instantiate()
	add_child(dialogue_instance)
	
	# Wait for dialogue to finish (it will queue_free itself when done)
	while dialogue_instance != null and is_instance_valid(dialogue_instance):
		await get_tree().process_frame
	
	# Small delay after dialogue ends
	await get_tree().create_timer(2).timeout
	
	# Now start the game
	game_start = true
	heartcontainer.setMaxHearts(Player.max_health)
	heartcontainer.updateHearts(Player.health)
	Player.healthChanged.connect(heartcontainer.updateHearts)
	
	var tween = create_tween()
	tween.tween_property(canvas, "modulate:a", 1.0, 0.8)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	spawn_square_enemy()
	spawn_circle_enemy()
	spawn_triangle_enemy()
	wave_function()

func _on_player_health_changed(current_health: int):
	# Check if we need to add more hearts (max health increased)
	var current_heart_count = heartcontainer.get_children().size()
	if Player.max_health > current_heart_count:
		# Add the missing hearts
		for i in range(current_heart_count, Player.max_health):
			heartcontainer.addHeart()
	
	# Update the heart display
	heartcontainer.updateHearts(current_health)

func scoreChange(points: int):
	cameraShake.emit()
	score += points
	if game_start:
		score_indicator.text = "Score: " + str(score)

func _end_game():
	sendScore.emit(score)
	
