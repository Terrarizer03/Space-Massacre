extends Camera2D

@onready var player = $"../Player"
@export var death_zoom_level: float = 1.5
@export var zoom_duration: float = 1.1

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player and player.has_signal("cameraZoom"):
		player.connect("cameraZoom", _on_camera_zoom)

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
