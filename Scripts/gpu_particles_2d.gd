extends GPUParticles2D

func _ready() -> void:
	
	speed_scale = 2
	await get_tree().create_timer(0.06).timeout
	speed_scale = 0.4
	
func _process(delta: float) -> void:
	pass
