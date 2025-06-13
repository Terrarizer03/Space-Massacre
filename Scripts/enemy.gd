extends CharacterBody2D

# INIT ===============
# signals -------------
signal Enemydeath

# preloads ---------------
var deathParticle = preload("res://Scenes/death_explosion.tscn")
var explosion = preload("res://Assets/Sound/explosion (1).wav")
var PowerUp = preload("res://Scenes/power_up.tscn")

# variables --------------
var health : float
var damaging_cooldown = 0
var player_in_body = false

# exports ---------------
@export var speed := 150.0
@export var MAX_HEALTH = 2.0
@export var attackingdamage = 1
@export var DAMAGING_COOLDOWN = 0.2

# On Ready -------------
@onready var collisionshape = $CollisionShape2D
@onready var player = $"../Player"
@onready var damage_hitbox = $DamageHitbox
@onready var hit_flash = $HitFlashAnimation

func _ready() -> void:
	platform_floor_layers = false
	var rand = randf_range(0.7, 1.5)
	scale = Vector2(rand, rand)
	health = floor(MAX_HEALTH * 2 * rand)
	speed /= rand
	
func _process(delta: float) -> void:
	if damaging_cooldown <= 0 and player_in_body == true:
		
		player.damage(attackingdamage, position)
		damaging_cooldown = DAMAGING_COOLDOWN
		
	damaging_cooldown -= delta
	
func _physics_process(_delta: float) -> void:
	if player:
		
		#DIRECTION CALCULATION
		#-------------------------------------------------------------
		var direction = (player.position - position).normalized() #normalized makes the vectors = to a percentage idk
		velocity = direction * speed 
		#-------------------------------------------------------------
		
		move_and_slide()
		
func damage(attack_damage, bullet):
	health -= attack_damage
	hit_flash.play("hit_flash")
	var main_scene = get_tree().get_first_node_in_group("MainScene")
	if health <= 0:
		Enemydeath.emit()
		spawnPowerUp()
		death(bullet)

func _on_damage_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_body = true

func _on_damage_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_body = false

func spawnPowerUp():
	var Pow_Up = PowerUp.instantiate()
	var rand1 = randi_range(1, 15)
	Pow_Up.global_position = global_position
	if rand1 == 10:
		get_tree().get_root().add_child(Pow_Up)
		print("Power Up Spawned!")
	else:
		return
	
func death(bullet):
	var deathParticle = preload("res://Scenes/death_explosion.tscn")
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = bullet.rotation
	_particle.emitting = true
	_particle.scale = scale * 1.5
	_particle.self_modulate = Color.html("#ff204e")
	get_tree().current_scene.add_child(_particle)
	explosion_noise()

func explosion_noise():
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = explosion
	get_parent().add_child(sound_player)
	sound_player.play()
	queue_free()
