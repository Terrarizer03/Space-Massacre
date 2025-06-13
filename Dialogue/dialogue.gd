extends CanvasLayer

var dialogue = [
	{ "name": "???", "text": "H-Hello? Is this signal being received?" },
	{ "name": "???", "text": "Well... if you're hearing this, I apologize." },
	{ "name": "???", "text": "*They* have you trapped and surrounded." },
	{ "name": "???", "text": "You know... I never imagined it would turn out this way." },
	{ "name": "???", "text": "I always thought you'd make it home." },
	{ "name": "???", "text": "But now... there's no rescue ship, no backup." },
	{ "name": "???", "text": "They're closing in. Fast." },
	{ "name": "???", "text": "This wasn't supposed to happen. Not to you." },
	{ "name": "???", "text": "I'm... I'm sorry." },
	{ "name": "???", "text": "Good luck." }
]

var current_dialogue_index = 0
var is_dialogue_active = false
var is_typing = false
var current_text = ""
var target_text = ""
var char_index = 0
var type_speed = 0.05  # Time between characters (lower = faster)
var time = 0.0

@onready var dialogue_sound = $DialogueSound
@onready var name_label = $NinePatchRect/Name
@onready var chat_label = $NinePatchRect/Chat
@onready var s_continue = $NinePatchRect/PressSpaceToContinue
@onready var type_timer = Timer.new()

func _ready() -> void:
	# Setup the typing timer
	add_child(type_timer)
	type_timer.wait_time = type_speed
	type_timer.timeout.connect(_on_type_timer_timeout)
	start_dialogue()

func _input(event):
	if is_dialogue_active and event.is_action_pressed("ui_accept"):
		if is_typing:
			# Skip the typing animation
			skip_typing()
		else:
			# Move to next dialogue
			next_dialogue()

func _process(delta: float) -> void:
	time += delta
	s_continue.self_modulate.a = (sin(time * 3.5) + 1.0) / 2.0

func start_dialogue():
	if dialogue.size() > 0:
		is_dialogue_active = true
		current_dialogue_index = 0
		show_current_dialogue()

func show_current_dialogue():
	if current_dialogue_index < dialogue.size():
		name_label.text = dialogue[current_dialogue_index]['name']
		target_text = dialogue[current_dialogue_index]['text']
		start_typing()
	else:
		end_dialogue()

func start_typing():
	is_typing = true
	current_text = ""
	char_index = 0
	chat_label.text = ""
	type_timer.start()

func _on_type_timer_timeout():
	if char_index < target_text.length():
		current_text += target_text[char_index]
		chat_label.text = current_text
		char_index += 1
		dialogue_sound.play()
	else:
		# Finished typing
		finish_typing()

func skip_typing():
	type_timer.stop()
	chat_label.text = target_text
	current_text = target_text
	char_index = target_text.length()
	finish_typing()

func finish_typing():
	is_typing = false
	type_timer.stop()

func next_dialogue():
	current_dialogue_index += 1
	if current_dialogue_index < dialogue.size():
		show_current_dialogue()
	else:
		end_dialogue()

func end_dialogue():
	is_dialogue_active = false
	visible = false
	queue_free()
