extends Camera2D

# INIT =============
# On Ready ------------
@onready var player = $"../Player"
@onready var main_scene = $"../../Node2D"

# export ----------
@export var death_zoom_level: float = 1.5
@export var zoom_duration: float = 1.1

#variables ---------
var shake_fade : float = 10.0
var _shake_strength: float = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player and player.has_signal("cameraZoom"):
		player.connect("cameraZoom", _on_camera_zoom)
	main_scene.cameraShake.connect(func(): camera_Shake(5.0))
	player.playerHit.connect(func(): camera_Shake(2.5))
		
func camera_Shake(max_shake):
	_shake_strength = max_shake
	
func _process(delta: float) -> void:
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
		offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))

func _on_camera_zoom():
	# Move camera to player position AND zoom in simultaneously
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_parallel(true)  # Allow multiple properties to tween at once
	
	# Move to player position
	tween.tween_property(self, "global_position", player.global_position, zoom_duration)
	
	# Zoom in
	tween.tween_property(self, "zoom", Vector2(death_zoom_level, death_zoom_level), zoom_duration)
	
	# Add easing
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade out music over 2 seconds
	var fade_tween = MusicManager.fade_out_music(7.5)
	await fade_tween.finished
	
	MusicManager.stop_music()
