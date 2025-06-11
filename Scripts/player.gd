extends CharacterBody2D

# INITIALIZE
# ==================
# unresolved -------------
var SPEED : float
var attack : float
var attack_cooldown : float

# preloads -------------
var bullet := preload("res://Scenes/Bullet.tscn")
var laser_shoot = preload("res://Assets/Sound/laserShoot.wav")

# variables -------------
var is_dashing = false
var shoot_ready = true
var bullet_scale = 1

# Exports -------------
@export var MAX_SPEED = 450.0
@export var friction = 0.1
@export var NORM_ATTACK = 1.0
@export var ATTACK_SPEED = 0.15

# On Ready -------------
@onready var screen_size = get_viewport_rect()
# ==================

func _ready() -> void:
	SPEED = MAX_SPEED
	attack = NORM_ATTACK
	attack_cooldown = ATTACK_SPEED
	
func _physics_process(delta: float) -> void:
	screen_wrap()
	# MOVEMENT ----------
	var direction = Vector2(Input.get_axis("key_left", "key_right"), Input.get_axis("key_up", "key_down"))
	var effective_speed = MAX_SPEED * 1
	
	if direction != Vector2.ZERO and not is_dashing:
		velocity = velocity.lerp(direction * effective_speed, 0.1)
	elif not is_dashing:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	
	# SHOOTING AND INPUTS ----------
	look_at(get_global_mouse_position())
	if Input.is_action_pressed("attack"):
		fire()
	
	move_and_slide()

func screen_wrap():
	position = position.posmodv(get_viewport_rect().size)

func fire():
	# BULLET INSTANTIATE ----------
	if shoot_ready:
		shoot_ready = false
		var bul_instance = bullet.instantiate()
		bul_instance.dir = rotation
		bul_instance.pos = $Node2D.global_position
		bul_instance.rota = global_rotation
		bul_instance.att = attack
		bul_instance.scale *= bullet_scale
		get_parent().add_child(bul_instance)
		$LaserShoot.play()
		# COOLDOWN
		# -----------
		await get_tree().create_timer(attack_cooldown).timeout
		shoot_ready = true
		# -----------

	# ================
