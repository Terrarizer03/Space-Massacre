extends Control

# INIT ==========
# signals --------------
signal StrengthCard
signal HealthCard
signal SpeedCard
signal AtkSpeedCard

# On Ready ----------------
@onready var sprites = $Sprite2D
@onready var DescriptionText = $Sprite2D/Description

# exports
@export var final_scale = 1.5
@export var hover_scale = 1.15
@export var scale_duration = 0.2
@export var fade_in_duration = 0.5

# variables --------------
var random = randi_range(0, 3)
var hovering = false
var original_position = null
var original_scale = null
var shake_time = 0.0
var description = {
	"Strength": "Increases Attack By 1",
	"Speed": "Increases movement speed by 10",
	"Health": "Increases Max Health by 1",
	"AtkSpeed": "Increases Attack Speed by 5%"
}

func _ready() -> void:
	original_scale = sprites.scale
	original_position = sprites.position
	sprites.frame = random
	checkDescription()
	
	# Start fade in animation
	fade_in_animation()
	
func _process(delta: float) -> void:
	if hovering:
		# Shaky rotation effect
		shake_time += delta * 4.0  # Speed of the shake
		var shake_intensity = 0.025  # How much it shakes
		sprites.rotation = sin(shake_time) * shake_intensity + cos(shake_time * 1.5) * shake_intensity * 0.5
	else:
		# Smoothly return to no rotation when not hovering
		sprites.rotation = lerp(sprites.rotation, 0.0, delta * 5.0)

func fade_in_animation():
	# Start 50 pixels below and invisible
	sprites.position.y = original_position.y + 50
	sprites.modulate.a = 0.0
	
	# Create tween for smooth fade in and movement
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple properties to animate simultaneously
	
	# Fade in
	tween.tween_property(sprites, "modulate:a", 1.0, fade_in_duration)
	
	# Move to original position
	tween.tween_property(sprites, "position:y", original_position.y, fade_in_duration)
	
	# Add easing for smooth animation
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

func checkDescription():
	if random == 0:
		DescriptionText.text = description["Strength"]
	elif random == 1:
		DescriptionText.text = description["Speed"]
	elif random == 2:
		DescriptionText.text = description["AtkSpeed"]
	else:
		DescriptionText.text = description["Health"]

func _on_button_pressed() -> void:
	if random == 0:
		StrengthCard.emit()
		queue_free()
	elif random == 1:
		SpeedCard.emit()
		queue_free()
	elif random == 2:
		AtkSpeedCard.emit()
		queue_free()
	else:
		HealthCard.emit()
		queue_free()

func _on_button_mouse_entered() -> void:
	hovering = true
	shake_time = 0.0  # Reset shake timer
	
	# Smooth scale up with tween
	var tween = create_tween()
	tween.tween_property(sprites, "scale", original_scale * hover_scale, scale_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
func _on_button_mouse_exited() -> void:
	hovering = false
	
	# Smooth scale down with tween
	var tween = create_tween()
	tween.tween_property(sprites, "scale", original_scale, scale_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
