extends Panel
@onready var sprite = $Sprite2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func update(whole: bool):
	# Check if this heart is the last child in its parent container
	var parent_container = get_parent()
	var is_last_heart = parent_container.get_child(-1) == self
	
	if is_last_heart:
		if whole: sprite.frame = 2  # Last heart, full
		else: sprite.frame = 3      # Last heart, empty
	else:
		if whole: sprite.frame = 0  # Regular heart, full
		else: sprite.frame = 1      # Regular heart, empty
