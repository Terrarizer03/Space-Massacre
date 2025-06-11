extends GPUParticles2D

func _ready() -> void:
	amount = randi_range(20,35)
	speed_scale = 3
	await get_tree().create_timer(0.07).timeout
	speed_scale = 0.5
	
func _process(delta: float) -> void:
	pass
