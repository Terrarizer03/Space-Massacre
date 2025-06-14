extends HBoxContainer
@onready var heartgui = preload("res://Scenes/PlayerHealth/heartgui.tscn")

func setMaxHearts(max: int):
	# Clear existing hearts first
	for child in get_children():
		child.queue_free()
	
	# Add new hearts
	for i in range(max):
		var heart = heartgui.instantiate()
		add_child(heart)

func addHeart():
	# Add a single new heart (for upgrades)
	var heart = heartgui.instantiate()
	add_child(heart)
		
func updateHearts(currentHealth: int):
	var hearts = get_children()
	
	for i in range(currentHealth):
		if i < hearts.size():
			hearts[i].update(true)
		
	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false)
