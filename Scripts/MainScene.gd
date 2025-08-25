extends Node2D

# SIGNALS
signal sendScore
signal cameraShake
signal waveEnd
signal endDeathMusic

# VARIABLES
var wave = 0
var score = 0
var game_start = false
var spawning = true
var spawned_enemies = 0
var game_running = true

# PRELOADS
var dialogue_scene = preload("res://Dialogue/dialogue.tscn")
var circle_enemy = preload("res://Scenes/Enemies/CircleEnemy.tscn")
var triangle_enemy = preload("res://Scenes/Enemies/TriangleEnemy.tscn")
var square_enemy = preload("res://Scenes/Enemies/SquareEnemy.tscn")
var background_music = preload("res://Assets/Sound/boss_battle_#2.WAV")

# ON READY
@onready var escape_panel = $Control/EscapePanel
@onready var wave_indicator = $CanvasLayer/Control/WaveIndicator
@onready var score_indicator = $"CanvasLayer/Control/ScoreIndicator"
@onready var heartcontainer = $CanvasLayer/Control/HBoxContainer
@onready var Player = $Player
@onready var canvas = $CanvasLayer/Control
@onready var UpgradePanel = $CanvasLayer/UpgradePanel
@onready var GameOverPanel = $CanvasLayer/GameOverPanel
@onready var FadeOverlay = $CanvasLayer/FadeOverlay

func _ready() -> void:
	print("Game starting...")
	# Ensure game is paused when scene loads
	get_tree().paused = false
	
	FadeOverlay.show()
	
	await get_tree().create_timer(0.5).timeout
	
	var tween = create_tween()
	tween.tween_property(FadeOverlay, "self_modulate:a", 0, 2.0)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(2).timeout
	
	FadeOverlay.hide()
	
	call_deferred("_start_game")

func _start_game():
	print("_start_game called")
	canvas.modulate.a = 0.0
	game_running = true
	
	# Connect signals - simple connections without checks for now
	Player.playerDeath.connect(_end_game)
	UpgradePanel.cardSelected.connect(_on_upgrade_selected)
	GameOverPanel.resetRequested.connect(_on_game_restart)
	GameOverPanel.endMusic.connect(_end_death_music)
	
	UpgradePanel.strengthUpgrade.connect(Player._on_strength_upgrade)
	UpgradePanel.healthUpgrade.connect(Player._on_health_upgrade)
	UpgradePanel.speedUpgrade.connect(Player._on_speed_upgrade)
	UpgradePanel.attackSpeedUpgrade.connect(Player._on_attack_speed_upgrade)

	Player.healthChanged.connect(_on_player_health_changed)

	print("Starting dialogue...")
	dialogueStart()

func _end_death_music() -> void:
	endDeathMusic.emit()

func dialogueStart():
	print("dialogueStart called")
	
	# Check if dialogue scene exists
	if dialogue_scene == null:
		print("Warning: dialogue_scene is null, skipping dialogue")
		_finish_dialogue_setup()
		return
	
	var dialogue_instance = dialogue_scene.instantiate()
	if dialogue_instance == null:
		print("Warning: Failed to instantiate dialogue, skipping")
		_finish_dialogue_setup()
		return
		
	add_child(dialogue_instance)
	
	# Wait for dialogue to finish
	while is_instance_valid(dialogue_instance):
		await get_tree().process_frame
	
	await get_tree().create_timer(2).timeout
	_finish_dialogue_setup()

func _finish_dialogue_setup():
	print("Finishing dialogue setup...")
	game_start = true
	
	MusicManager.play_music(0, background_music)
	
	# Setup hearts
	if heartcontainer and Player:
		heartcontainer.setMaxHearts(Player.max_health)
		heartcontainer.updateHearts(Player.health)
		Player.healthChanged.connect(heartcontainer.updateHearts)

	# Fade in canvas
	var fade_tween = create_tween()
	fade_tween.tween_property(canvas, "modulate:a", 1.0, 0.8)
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Start game systems
	print("Starting enemy spawns and wave loop...")
	_start_spawners()
	_start_wave_loop()

func _start_spawners():
	spawn_circle_enemy()
	spawn_triangle_enemy()
	spawn_square_enemy()

func _start_wave_loop():
	_wave_loop()

# -----------------------
# SPAWN FUNCTIONS
# -----------------------
func spawn_circle_enemy() -> void:
	while game_running:
		if spawning and game_running:
			spawned_enemies += 1
			var circle_instance = circle_enemy.instantiate()
			circle_instance.position = determineSpawnPos()
			circle_instance.MAX_HEALTH = floor(circle_instance.MAX_HEALTH + (wave / 4)) 
			add_child(circle_instance)
			circle_instance.Enemydeath.connect(func(): scoreChange(10))
			await get_tree().create_timer(1).timeout
		else:
			await get_tree().create_timer(0.1).timeout

func spawn_triangle_enemy() -> void:
	while game_running:
		if spawning and wave >= 3 and game_running:
			spawned_enemies += 1
			var triangle_instance = triangle_enemy.instantiate()
			triangle_instance.position = determineTriangleSpawnPos()
			triangle_instance.MAX_HEALTH = floor(triangle_instance.MAX_HEALTH + (wave / 4))
			add_child(triangle_instance)
			triangle_instance.Enemydeath.connect(func(): scoreChange(15))
			await get_tree().create_timer(5).timeout
		else:
			await get_tree().create_timer(0.1).timeout

func spawn_square_enemy() -> void:
	while game_running:
		if spawning and wave >= 5 and game_running:
			spawned_enemies += 1
			var square_instance = square_enemy.instantiate()
			square_instance.position = determineSquareSpawnPos()
			square_instance.MAX_HEALTH = floor(square_instance.MAX_HEALTH + (wave / 6))
			add_child(square_instance)
			square_instance.Enemydeath.connect(func(): scoreChange(25))
			await get_tree().create_timer(20).timeout
		else:
			await get_tree().create_timer(0.1).timeout

# -----------------------
# WAVE LOOP
# -----------------------
func _wave_loop() -> void:
	while game_running:
		if game_running:
			await wave_function()
		else:
			break

func wave_function() -> void:
	if not game_running:
		return
	
	if wave >= 1:
		$WaveEndSound.play()

	wave += 1
	spawning = true
	spawned_enemies = 0

	wave_indicator.text = "Wave " + str(wave)
	score_indicator.text = "Score: " + str(score)

	# Spawn duration increases with wave number
	var spawn_duration = 8 + (wave * 2)
	await get_tree().create_timer(spawn_duration).timeout
	
	if not game_running:
		return
	
	spawning = false

	# Wait for all enemies to be defeated
	while get_tree().get_nodes_in_group("Enemy").size() > 0 and game_running:
		await get_tree().process_frame

	if not game_running:
		return

	print("WAVE ", wave, " ENDED - Enemies spawned: ", spawned_enemies)

	if wave % 2 == 1:
		# Show upgrade panel
		UpgradePanel.show()
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(UpgradePanel, "modulate:a", 1.0, 0.8)
		fade_in_tween.set_trans(Tween.TRANS_SINE)
		fade_in_tween.set_ease(Tween.EASE_IN_OUT)
		await fade_in_tween.finished

		if not game_running:
			return

		UpgradePanel.spawnCards()
		await UpgradePanel.cardSelected

		if not game_running:
			return

		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(UpgradePanel, "modulate:a", 0.0, 0.8)
		fade_out_tween.set_trans(Tween.TRANS_SINE)
		fade_out_tween.set_ease(Tween.EASE_IN_OUT)
		await fade_out_tween.finished
		UpgradePanel.hide()

		await get_tree().create_timer(1.0).timeout
	else:
		await get_tree().create_timer(5.0).timeout

# -----------------------
# RESTART FUNCTIONS
# -----------------------
func _on_game_restart():
	print("Game restart requested")
	
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()

# -----------------------
# OTHER FUNCTIONS
# -----------------------
func _on_upgrade_selected():
	print("Upgrade selected for wave ", wave)

func determineSpawnPos():
	var screen_width = 1152
	var screen_height = 648
	var spawn_margin = 50
	var side = randi() % 4
	var pos = Vector2()
	match side:
		0: pos = Vector2(-spawn_margin, randf() * screen_height)
		1: pos = Vector2(screen_width + spawn_margin, randf() * screen_height)
		2: pos = Vector2(randf() * screen_width, -spawn_margin)
		3: pos = Vector2(randf() * screen_width, screen_height + spawn_margin)
	return pos

func determineTriangleSpawnPos():
	var screen_width = 1152
	var screen_height = 648
	var margin = 50
	return Vector2(randf_range(margin, screen_width - margin), randf_range(margin, screen_height - margin))

func determineSquareSpawnPos():
	var screen_width = 1152
	var screen_height = 648
	var spawn_margin = 100
	var side = randi() % 4
	var pos = Vector2()
	match side:
		0: pos = Vector2(-spawn_margin, randf() * screen_height)
		1: pos = Vector2(screen_width + spawn_margin, randf() * screen_height)
		2: pos = Vector2(randf() * screen_width, -spawn_margin)
		3: pos = Vector2(randf() * screen_width, screen_height + spawn_margin)
	return pos

func _on_player_health_changed(current_health: int):
	if not heartcontainer or not Player:
		return
		
	var current_heart_count = heartcontainer.get_children().size()
	if Player.max_health > current_heart_count:
		for i in range(current_heart_count, Player.max_health):
			heartcontainer.addHeart()
	heartcontainer.updateHearts(current_health)

func scoreChange(points: int):
	if not game_running:
		return
		
	cameraShake.emit()
	score += points
	if game_start:
		score_indicator.text = "Score: " + str(score)

func _end_game():
	game_running = false
	spawning = false
	
	sendScore.emit(score)
