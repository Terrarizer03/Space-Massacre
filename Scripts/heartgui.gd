extends Panel
@onready var sprite = $Sprite2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func update(whole: bool):
	# Check if this heart is the last child in its parent container
	var parent_container = get_parent()
	
	if whole: sprite.frame = 0 
	else: sprite.frame = 1     
