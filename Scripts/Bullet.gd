extends CharacterBody2D

# INIT
# ================
var pos: Vector2
var rota: float
var dir: float
var speed = 1500
var att : float
var camera = null
var outofbounds = false
@onready var area = $Area2D
# ================

func _ready():
	$CollisionShape2D.disabled = true
	global_position = pos
	global_rotation = rota
	
func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("damage") and not body.is_in_group("Player"):
		body.damage(att, self)
		death()

func death():
	if outofbounds == false:
		var deathParticle = preload("res://Scenes/bulletexplosion particles.tscn")
		var _particle = deathParticle.instantiate()
		_particle.position = global_position
		_particle.rotation = rotation + deg_to_rad(180)
		_particle.amount = randi_range(3,10)
		_particle.scale = Vector2(0.7,0.7)
		_particle.emitting = true
		get_tree().current_scene.add_child(_particle)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	outofbounds = true
	await get_tree().create_timer(0.25).timeout
	print("Out of Bounds")
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	outofbounds = false
