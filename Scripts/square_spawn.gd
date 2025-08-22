extends CharacterBody2D

#MAKING VARIABLES
#-------------------------------------------------------------
@export var speed := 150.0
@onready var collisionshape = $Collision
@onready var player = $"../Player"
@onready var damage_hitbox = $DamageHitbox
@onready var sprite = $Sprite2D
@onready var white_sprite = $Sprite2D/White
@onready var hit_effect_timer = $HitEffectTimer
@onready var hit_effect = $HitEffect
@export var MAX_HEALTH = 2.0
@export var attackingdamage = 1
@export var DAMAGING_COOLDOWN := 0.2

var explosion = preload("res://Assets/Sound/explosion (1).wav")
var deathParticle = preload("res://Scenes/death_explosion.tscn")
var power_up = preload("res://Scenes/power_up.tscn")
var health: float
var damaging_cooldown = 0
var size_scale = 1
var player_in_body = false
var modulation = 200

func _ready() -> void:
	platform_floor_layers = false

func creation(parentscale):
	scale = parentscale / 2
	speed /= scale.x
	health = MAX_HEALTH

func _process(delta: float) -> void:
	if damaging_cooldown <= 0 and player_in_body == true:
		player.damage(attackingdamage, position)
		damaging_cooldown = DAMAGING_COOLDOWN
	damaging_cooldown -= delta

func _physics_process(delta: float) -> void:
	sprite.rotation += 2 * delta / 2 * size_scale
	if player:
		
		#DIRECTION CALCULATION
		#-------------------------------------------------------------
		var direction = (player.position - position).normalized() #normalized makes the vectors = to a percentage idk
		velocity = direction * speed 
		#-------------------------------------------------------------
		
		move_and_slide()

func damage(attack_damage,bullet):
	health -= attack_damage
	hit_effect.play("HitFlash")
	# var main_scene = get_tree().get_first_node_in_group("MainScene")
	if health <= 0:
		death()

func _on_damage_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_body = true
		
func _on_damage_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_body = false

func instan():
	var Pow_Up = power_up.instantiate()
	var rand1 = randi_range(1, 15)

	Pow_Up.global_position = global_position
	if rand1 == 10:
		get_tree().get_root().add_child(Pow_Up)
		print("Power Up Spawned!")
	else:
		return
	
func death():
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.look_at(player.global_position)
	_particle.rotation += 180
	_particle.emitting = true
	_particle.self_modulate = Color.html("#535c91")
	get_tree().current_scene.add_child(_particle)
	explosion_noise()

func explosion_noise():
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = explosion
	sound_player.volume_db = -7.5
	get_parent().add_child(sound_player)
	sound_player.play()
	queue_free()
