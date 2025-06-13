extends CharacterBody2D

# INIT
# ===============================
# signals -------------
signal Enemydeath

# Exports ------------
@export var attackingdamage = 1
@export var DAMAGING_COOLDOWN = 0.5
@export var speed := 1000.0

@onready var player = $"../Player"
@onready var tween = get_tree().create_tween()
# ===============================

# PRELOADS
# -------------------------------
var explosion = preload("res://Assets/Sound/explosion (1).wav")
var deathParticle = preload("res://Scenes/death_explosion.tscn")
var PowerUp = preload("res://Scenes/power_up.tscn")
var bullet = preload("res://Scenes/Bullet.tscn")
# -------------------------------

var rand_num = randf_range(1, 1.25)
var final_scale = Vector2(rand_num, rand_num)
var has_bullets = true
var MAX_BULLETS = randi_range(5, 10)
var bullet_amount : float
var health: float
var damaging_cooldown = 0
# ===============================

func _ready() -> void:
	health = randi_range(2, 3)
	bullet_amount = MAX_BULLETS
	scale = Vector2(0.1, 0.1)
	tween.tween_property(self, "scale", final_scale, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	speed *= rand_num
	$FireTimer.start()

func _physics_process(_delta: float) -> void:
	look_at(player.global_position)
	
	if has_bullets == false:
		dash()
	else:
		return
		
	move_and_slide()

func dash():
	var direction = (player.position - position).normalized()
	var distance = position.distance_to(player.position)
	var t = clamp(distance / 500.0, 0, 1)
	var eased_t = pow(t, 3.0)
	velocity = velocity.lerp(direction * speed, eased_t)

func damage(attack_damage, bullet):
	health -= attack_damage
	print(health)
	$HitEffect.play("HitEffect")
	var main_scene = get_tree().get_first_node_in_group("MainScene")
	if health <= 0:
		Enemydeath.emit()
		spawnPowerUp()
		death()

func _on_damage_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("damage") and damaging_cooldown <= 0:
		body.damage(attackingdamage, position)
		damaging_cooldown = DAMAGING_COOLDOWN
		death()

func fire():
	# BULLET INSTANTIATE
	# ================
	var rand_scale = randf_range(0.075, 0.125)
	var bul_instance = bullet.instantiate()
	bul_instance.shooter = self
	bul_instance.is_player_bullet = self.is_in_group("Enemy")
	bul_instance.modulate = Color8(0, 255, 0)
	bul_instance.dir = rotation
	bul_instance.pos = $Node2D.global_position
	bul_instance.rota = global_rotation
	bul_instance.speed = 1000
	bul_instance.att = 1.0
	bul_instance.scale = Vector2(rand_scale, rand_scale)
	get_parent().add_child(bul_instance)
	# ================
	
func _on_fire_timer_timeout() -> void:
	bullet_amount -= 1
	fire()
	if bullet_amount == 0:
		has_bullets = false
		$FireTimer.stop()
		
func spawnPowerUp():
	var Pow_Up = PowerUp.instantiate()
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
	_particle.rotation = global_rotation
	_particle.emitting = true
	_particle.self_modulate = Color(0, 1, 0)
	get_tree().current_scene.add_child(_particle)
	explosion_noise()
	queue_free()

func explosion_noise():
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = explosion
	get_parent().add_child(sound_player)
	sound_player.play()
