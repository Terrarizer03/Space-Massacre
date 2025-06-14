extends Panel

# signals -----------
signal cardSelected
signal strengthUpgrade
signal healthUpgrade
signal speedUpgrade
signal attackSpeedUpgrade

# preloads -----------
var UpgradeCards = preload("res://Scenes/UpgradeScenes/UpgradeCards.tscn")

# OnReady references for better performance
@onready var spawn_points = [$SpawnPoint1, $SpawnPoint2, $SpawnPoint3]

# Variables for card management
var spawned_cards = []
var card_selected = false

func _ready() -> void:
	self.hide()
	self.modulate.a = 0.0

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
		
		# Connect to all the card signals for selection tracking
		upgrade_instance.StrengthCard.connect(_on_strength_card_selected.bind(upgrade_instance))
		upgrade_instance.HealthCard.connect(_on_health_card_selected.bind(upgrade_instance))
		upgrade_instance.SpeedCard.connect(_on_speed_card_selected.bind(upgrade_instance))
		upgrade_instance.AtkSpeedCard.connect(_on_attack_speed_card_selected.bind(upgrade_instance))
		
		# Optional: Add a small delay between spawns for visual effect
		if i < spawn_points.size() - 1:  # Don't wait after the last card
			await get_tree().create_timer(0.25).timeout

func _on_strength_card_selected(selected_card):
	if card_selected:
		return
	_handle_card_selection(selected_card)
	strengthUpgrade.emit()

func _on_health_card_selected(selected_card):
	if card_selected:
		return
	_handle_card_selection(selected_card)
	healthUpgrade.emit()

func _on_speed_card_selected(selected_card):
	if card_selected:
		return
	_handle_card_selection(selected_card)
	speedUpgrade.emit()

func _on_attack_speed_card_selected(selected_card):
	if card_selected:
		return
	_handle_card_selection(selected_card)
	attackSpeedUpgrade.emit()

func _handle_card_selection(selected_card):
	card_selected = true
	
	# Start fade out animations for all other cards
	var fade_tweens = []
	for card in spawned_cards:
		if card != selected_card:
			var tween = fade_out_card(card)
			fade_tweens.append(tween)
	
	# Wait for all fade animations to complete
	for tween in fade_tweens:
		await tween.finished
	
	# Emit the generic card selected signal after animations
	cardSelected.emit()

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
	
	# Return the tween so we can wait for it
	return tween

func clearCards():
	# Remove all existing cards before spawning new ones
	for spawn_point in spawn_points:
		for child in spawn_point.get_children():
			if child.has_method("queue_free"):
				child.queue_free()

# Optional: Method to respawn cards (useful for rerolls)
func respawnCards():
	spawnCards()
