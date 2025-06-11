extends Area2D

# INIT ===============
# variables ------------
var power_ups = {
	"Strength": "strength_power_up",
	"Speed": "speed_power_up",
	"AttackSpeed": "attack_speed_power_up"
}
var current_power_up = null

# On Ready -----------
@onready var sprite = $Sprite2D
# ==================

func _ready() -> void:
	$PowerUpAnimation.play("Idle")
	current_power_up = determinePowerUp()
	
func determinePowerUp():
	var randomPowerUp = randi_range(1, 3)
	
	if randomPowerUp == 1:
		sprite.modulate = Color8(255, 0, 0)
		return power_ups["Strength"]
	elif randomPowerUp == 2:
		sprite.modulate = Color8(255, 255, 0)
		return power_ups["AttackSpeed"]
	else:
		sprite.modulate = Color8(0, 200, 255)
		return power_ups["Speed"]

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method(current_power_up):
			body.call(current_power_up)  # Use call() to invoke the method by name
			print(current_power_up, " Power Up Called!")
		else:
			print(body, " Has no method: ", current_power_up)
		queue_free()
