extends CharacterBody2D

# INIT ==============
# signals -------------
signal Enemydeath

# variables --------------
var player_in_body = false
var health : float
var damaging_cooldown = 0
var size_scale = 1
var rotationdir = +1
var highest_health
var shield_broken = false
var shield_health = 5
var camera = null
var shield_regen_timer = 0.0
var shield_regen_delay = 5.0

# On Ready --------------
@onready var collisionshape = $Collision
@onready var player = $"../Player"
@onready var damage_hitbox = $DamageHitbox
@onready var sprite = $Sprite2D
@onready var spawn_nodes = [$Node2D, $Node2D2, $Node2D3, $Node2D4]
@onready var hit_effect = $HitEffect
@onready var spawn_timer = $SpawnTimer
@onready var shield_broken_timer = $ShieldBrokenSpawnTimer

# exports -------------
@export var MAX_HEALTH = 3.0
@export var attackingdamage = 1
@export var DAMAGING_COOLDOWN = 0.2
@export var speed := 70.0

# preloads -------------
var explosion = preload("res://Assets/Sound/explosion (1).wav")
var power_d = preload("res://Assets/Sound/blipSelect (1).wav")
var deathParticle = preload("res://Scenes/death_explosion.tscn")
var power_up = preload("res://Scenes/power_up.tscn")
var square_spawn = preload("res://Scenes/Enemies/SquareSpawn.tscn")

func _ready() -> void:
	platform_floor_layers = false
	size_scale = randf_range(3, 5)
	scale = Vector2(size_scale, size_scale)
	health = floor(MAX_HEALTH * 1.3 * size_scale)
	highest_health = health
	
	var rand = randi_range(0, 1)
	rotationdir = 1 if rand == 1 else -1
	
	await get_tree().create_timer(10).timeout
	spawn_squares(1, true, true)

func _process(delta: float) -> void:
	# Update shield transparency
	sprite.self_modulate.a8 = 255 / 5 * shield_health
	
	# Handle player damage
	if damaging_cooldown <= 0 and player_in_body:
		player.damage(attackingdamage, position)
		damaging_cooldown = DAMAGING_COOLDOWN
	damaging_cooldown -= delta
	
	# Handle shield breaking
	if shield_health <= 0 and not shield_broken:
		collisionshape.scale /= 2
		damage_hitbox.scale /= 2
		power_down()
		shield_broken = true
		shield_regen_timer = shield_regen_delay  # Start the regen timer
		spawn_squares(randi_range(1, 5), false, false)
	
	# Handle shield regeneration timer
	if shield_broken:
		shield_regen_timer -= delta
		if shield_regen_timer <= 0:
			regenerate_shield()

func _physics_process(delta: float) -> void:
	sprite.rotation += 2 * delta / size_scale * rotationdir
	$Sprite2D/Sprite2D.rotation -= 4 * delta / size_scale * rotationdir
	
	if player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed 
		move_and_slide()

func damage(attack_damage, bullet):
	if shield_health > 0:
		if attack_damage > shield_health:
			health -= attack_damage - shield_health
			shield_health = 0
		else:
			shield_health -= attack_damage
	else:
		health -= attack_damage
		# Reset shield regen timer if hit while shield is down
		if shield_broken:
			shield_regen_timer = shield_regen_delay
		
	play_hit_effect()
	
	if health <= 0:
		Enemydeath.emit()
		death()

func regenerate_shield():
	shield_broken = false
	collisionshape.scale *= 2
	damage_hitbox.scale *= 2 
	sprite.self_modulate.a8 = 255
	
	# Gradually restore shield health
	for i in range(1, 5):
		if shield_health != 5:
			shield_health += 1
		await get_tree().create_timer(0.8).timeout

func play_hit_effect():
	if not shield_broken:
		hit_effect.play("Shield_HitFlash")
	else:
		hit_effect.play("RBody_HitFlash")

func _on_damage_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_body = true

func _on_damage_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_body = false

func spawn_squares(count, repeat, wait):
	if wait:
		speed = 0
		await get_tree().create_timer(5).timeout
		for i in range(count):
			create_square()
	else:
		for i in range(count):
			await get_tree().create_timer(0.2).timeout
			create_square()
	
	if repeat:
		spawn_squares(1, true, true)

func create_square():
	var instance = square_spawn.instantiate()
	get_parent().add_child(instance)
	var rand_node = spawn_nodes[randi_range(0, 3)]
	instance.position = rand_node.global_position
	var spawn_scale = scale / 1.5 if shield_broken else scale
	instance.creation(spawn_scale)

func spawn_power_up():
	var rand1 = randi_range(1, 10)
	if rand1 == 10:
		var pow_up = power_up.instantiate()
		pow_up.global_position = global_position
		get_tree().get_root().add_child(pow_up)
		print("Power Up Spawned!")

func death():
	var particle = deathParticle.instantiate()
	particle.position = global_position
	particle.look_at(player.global_position)
	particle.rotation += 180
	particle.emitting = true
	particle.scale = scale * 1.5
	particle.self_modulate = Color.html("#3d3bf3")
	get_tree().current_scene.add_child(particle)
	
	explosion_noise()
	spawn_power_up()
	queue_free()

func explosion_noise():
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = explosion
	get_parent().add_child(sound_player)
	sound_player.play()

func power_down():
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = power_d
	get_parent().add_child(sound_player)
	sound_player.play()
