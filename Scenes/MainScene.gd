extends Node2D

# INIT =============
# variables -------------
var wave = 0
var spawning = true
var spawned_enemies = 0

# preloads ------------
var circle_enemy = preload("res://Scenes/enemy.tscn")

func _ready() -> void:
	spawn_circle_enemy()
	wave_function()

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

func wave_function():
	wave += 1
	spawning = true
	spawned_enemies = 0
	
	print("WAVE ", wave, " STARTED")
	
	# Spawn duration increases with wave number
	var spawn_duration = 8 + (wave * 2)  # 10s, 12s, 14s, etc.
	
	# Wait for spawn duration
	await get_tree().create_timer(spawn_duration).timeout
	spawning = false
	
	print("WAVE ", wave, " ENDED - Enemies spawned: ", spawned_enemies)
	
	# Break duration between waves
	var break_duration = 5
	await get_tree().create_timer(break_duration).timeout
	
	# Start next wave
	wave_function()

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
