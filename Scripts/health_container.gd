extends HBoxContainer

@onready var heartgui = preload("res://Scenes/PlayerHealth/heartgui.tscn")

func setMaxHearts(max: int):
	for i in range(max):
		var heart = heartgui.instantiate()
		add_child(heart)
		
func updateHearts(currentHealth: int):
	var hearts = get_children()
	
	for i in range(currentHealth):
		hearts[i].update(true)
		
	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false)
