extends Panel

# preloads -----------
var UpgradeCards = preload("res://Scenes/UpgradeScenes/UpgradeCards.tscn")

# OnReady references for better performance
@onready var spawn_points = [$SpawnPoint1, $SpawnPoint2, $SpawnPoint3]

# Variables for card management
var spawned_cards = []
var card_selected = false

func _ready() -> void:
	# Spawn cards automatically when ready
	spawnCards()

func spawnCards():
	# Clear any existing cards first
	clearCards()
	card_selected = false
	spawned_cards.clear()
	
	# Spawn one card at each spawn point
	for i in range(spawn_points.size()):
		var upgrade_instance = UpgradeCards.instantiate()
		upgrade_instance.position = spawn_points[i].position
		add_child(upgrade_instance)
		spawned_cards.append(upgrade_instance)
		
		# Connect to all the card signals
		upgrade_instance.StrengthCard.connect(_on_card_selected.bind(upgrade_instance))
		upgrade_instance.HealthCard.connect(_on_card_selected.bind(upgrade_instance))
		upgrade_instance.SpeedCard.connect(_on_card_selected.bind(upgrade_instance))
		upgrade_instance.AtkSpeedCard.connect(_on_card_selected.bind(upgrade_instance))
		
		# Optional: Add a small delay between spawns for visual effect
		if i < spawn_points.size() - 1:  # Don't wait after the last card
			await get_tree().create_timer(0.1).timeout

func _on_card_selected(selected_card):
	if card_selected:
		return  # Prevent multiple selections
	
	card_selected = true
	
	# Fade out all other cards
	for card in spawned_cards:
		if card != selected_card:
			fade_out_card(card)

func fade_out_card(card):
	# Create fade out tween
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out the card
	tween.tween_property(card, "modulate:a", 0.0, 0.5)
	
	# Optional: Scale down slightly for extra effect
	tween.tween_property(card, "scale", card.scale * 0.8, 0.5)
	
	# Add easing
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)

func clearCards():
	# Remove all existing cards before spawning new ones
	for spawn_point in spawn_points:
		for child in spawn_point.get_children():
			if child.has_method("queue_free"):
				child.queue_free()

# Optional: Method to respawn cards (useful for rerolls)
func respawnCards():
	spawnCards()
