extends CharacterBody2D

# INITIALIZE
# ==================
# signals -------------
signal healthChanged
signal playerDeath
signal cameraZoom
signal playerHit

# unresolved -------------
var SPEED : float
var attack : float
var attack_cooldown : float
var health : float

# preloads -------------
var bullet := preload("res://Scenes/Bullet.tscn")
var laser_shoot = preload("res://Assets/Sound/laserShoot.wav")

# variables -------------
var shoot_ready = true
var speed_up = false
var atk_speed_up = false
var atk_up = false
var bullet_scale = 1
var iframes = false
var is_alive = true
var attackmult := 2
var speedmult := 1.5
var is_dashing = false
var can_dash = true
var dash_speed = 1000.0
var dash_duration = 0.2
var dash_cooldown = 0.5


# Exports -------------
@export var MAX_SPEED = 450.0
@export var friction = 0.1
@export var NORM_ATTACK = 1.0
@export var ATTACK_SPEED = 0.15
@export var max_health = 5.0

# On Ready -------------
@onready var screen_size = get_viewport_rect()
@onready var cards
@onready var PlayerSprite = $Sprite2D

# ==================

func _ready() -> void:
	SPEED = MAX_SPEED
	attack = NORM_ATTACK
	attack_cooldown = ATTACK_SPEED
	health = max_health
	
func _physics_process(delta: float) -> void:
	screen_wrap()
	# MOVEMENT ----------
	var direction = Vector2(Input.get_axis("key_left", "key_right"), Input.get_axis("key_up", "key_down"))
	var effective_speed = MAX_SPEED * (speedmult if speed_up else 1)
	
	if direction != Vector2.ZERO and not is_dashing:
		velocity = velocity.lerp(direction * effective_speed, 0.1)
	elif not is_dashing:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	
	if is_alive:
		look_at(get_global_mouse_position())
	else:
		return
	
	# SHOOTING AND INPUTS ----------
	if Input.is_action_pressed("attack"):
		fire()
	
	if Input.is_action_just_pressed("dash"):
		dash()
	
	move_and_slide()

func screen_wrap():
	position = position.posmodv(get_viewport_rect().size)

func fire():
	# BULLET INSTANTIATE ----------
	if shoot_ready:
		shoot_ready = false
		var bul_instance = bullet.instantiate()
		bul_instance.shooter = self
		bul_instance.is_player_bullet = self.is_in_group("Player")
		bul_instance.dir = rotation
		bul_instance.pos = $Node2D.global_position
		bul_instance.rota = global_rotation
		bul_instance.att = attack
		bul_instance.scale *= bullet_scale
		bul_instance.speed = 1500
		get_parent().add_child(bul_instance)
		$LaserShoot.play()
		# COOLDOWN
		# -----------
		await get_tree().create_timer(attack_cooldown).timeout
		shoot_ready = true
		# -----------
		
func damage(attack_damage,pos):
	if iframes == false:
		var push_direction = (position - pos).normalized()
		velocity = push_direction * SPEED * 2
		health -= attack_damage
		healthChanged.emit(health)
		playerHit.emit()
		$HitSound.play()
		Iframes(0.5)
		if health <= 0:
			is_alive = false
			cameraZoom.emit()
			await $PlayerAnimations.animation_finished
			# Pause the game but allow player to animate
			get_tree().paused = true
			process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			$PlayerAnimations.play("PlayerDeath")
			await $PlayerAnimations.animation_finished
			playerDeath.emit()
			
func Iframes(time):
	iframes = true
	$PlayerAnimations.play("Hit")
	await get_tree().create_timer(time).timeout
	iframes = false

func create_dash_trail():
	var ghost = Sprite2D.new()
	ghost.texture = PlayerSprite.texture  
	ghost.hframes = PlayerSprite.hframes  # Set the horizontal frames
	ghost.vframes = PlayerSprite.vframes  # Set the vertical frames
	ghost.frame = 0  # Use frame 0 (the first frame)
	ghost.global_position = global_position  
	ghost.global_rotation = global_rotation + deg_to_rad(90) 
	ghost.scale = scale * 2.5
	ghost.modulate = Color(1, 1, 1, 0.5)  
	
	get_parent().add_child(ghost)  # Add to the scene
	
	# Tween to fade out and remove the ghost
	var tween = get_tree().create_tween()
	tween.tween_property(ghost, "modulate:a", 0, 0.3)  # Fade out in 0.3s
	await tween.finished
	ghost.queue_free()  # Delete after fading out
# ------------------------------------ #

func dash():
	if is_dashing or not can_dash:
		return  # Prevent multiple dashes at once

	can_dash = false
	is_dashing = true
	iframes = true # Optional: Make the player invincible during dash
	PlayerSprite.self_modulate.a8 = 100
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)

	var dash_direction = velocity.normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT.rotated(rotation)  # Default to facing direction if not moving

	velocity = dash_direction * dash_speed
	var trail_timer = dash_duration / 5  # Adjust this for smoother trails
	for i in range(5):  # Create 5 ghost images
		create_dash_trail()
		await get_tree().create_timer(trail_timer).timeout  # Small delay
	
	PlayerSprite.self_modulate.a8 = 255
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	is_dashing = false
	iframes = false  # Remove invincibility
	velocity = Vector2.ZERO  # Stop the dash
	await get_tree().create_timer(dash_cooldown).timeout
	
	can_dash = true  # Reset cooldown

# Power Ups ==================
func strength_power_up():
	$PickupCoin.play()
	if atk_up:
		return
	else:
		atk_up = true
		attack = NORM_ATTACK * attackmult
		await get_tree().create_timer(10).timeout
		$PowerDown.play()
		attack = NORM_ATTACK
		atk_up = false

func speed_power_up():
	$PickupCoin.play()
	speed_up = true
	await get_tree().create_timer(10).timeout
	$PowerDown.play()
	speed_up = false

func attack_speed_power_up():
	$PickupCoin.play()
	if atk_speed_up:
		return
	else:
		atk_speed_up = true
		var previous_attack_cooldown = attack_cooldown
		attack_cooldown /= 1.5
		await get_tree().create_timer(10).timeout
		$PowerDown.play()
		attack_cooldown = previous_attack_cooldown
		atk_speed_up = false

func health_power_up():
	$PickupCoin.play()
	if health == max_health:
		return
	else:
		health += 1
		healthChanged.emit(health)
# ================
