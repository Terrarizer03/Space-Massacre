extends Node2D

# INIT =============
# variables -------------
var wave = 0
var spawning = true
var spawned_enemies = 0

# preloads ------------
var dialogue_scene = preload("res://Dialogue/dialogue.tscn")
var circle_enemy = preload("res://Scenes/Enemies/CircleEnemy.tscn")
var triangle_enemy = preload("res://Scenes/Enemies/TriangleEnemy.tscn")
var square_enemy = preload("res://Scenes/Enemies/SquareEnemy.tscn")

# On Ready -------------
@onready var wave_indicator = $CanvasLayer/WaveIndicator
@onready var heartcontainer = $CanvasLayer/HBoxContainer
@onready var Player = $Player

func _ready() -> void:
	gameStart()

func spawn_circle_enemy():
	while true:
		if spawning:
			spawned_enemies += 1
			var spawnpos = determineSpawnPos()
			
			var circle_instance = circle_enemy.instantiate()
			circle_instance.position = spawnpos
			add_child(circle_instance)
			print("ENEMY SPAWNED ", circle_instance.position)
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
			print("TRIANGLE ENEMY SPAWNED ", triangle_instance.position)
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
			print("ENEMY SPAWNED ", square_instance.position)
			await get_tree().create_timer(10).timeout
		else:
			await get_tree().create_timer(0.1).timeout

func wave_function():
	if wave >= 1:
		$WaveEndSound.play()
	wave += 1
	spawning = true
	spawned_enemies = 0
	
	wave_indicator.text = "Wave " + str(wave)
	
	# Spawn duration increases with wave number
	var spawn_duration = 8 + (wave * 2)  # 10s, 12s, 14s, etc.
	
	# Wait for spawn duration
	await get_tree().create_timer(spawn_duration).timeout
	spawning = false
	
	while get_tree().get_nodes_in_group("Enemy").size() > 0:
		await get_tree().process_frame
	
	print("WAVE ", wave, " ENDED - Enemies spawned: ", spawned_enemies)
	
	# Break duration between waves
	var break_duration = 5
	await get_tree().create_timer(break_duration).timeout
	
	# Start next wave
	wave_function()

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

func gameStart():
	# Instantiate and show dialogue
	var dialogue_instance = dialogue_scene.instantiate()
	add_child(dialogue_instance)
	
	# Wait for dialogue to finish (it will queue_free itself when done)
	while dialogue_instance != null and is_instance_valid(dialogue_instance):
		await get_tree().process_frame
	
	# Small delay after dialogue ends
	await get_tree().create_timer(2).timeout
	
	# Now start the game
	heartcontainer.setMaxHearts(Player.max_health)
	heartcontainer.updateHearts(Player.health)
	Player.healthChanged.connect(heartcontainer.updateHearts)
	spawn_square_enemy()
	spawn_circle_enemy()
	spawn_triangle_enemy()
	wave_function()
