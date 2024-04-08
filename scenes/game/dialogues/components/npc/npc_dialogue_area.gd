extends Node2D
## Class that controls NPC dialogue events 
## 
## Controls the start and end events of NPC dialogues


# Dialogue signal definition
signal talk()

# Dialogue ended signal definition
signal dialogue_ended()
# Signal that listens when a dialogue response is selected
signal response_selected(response: String)

# The NPC, which will have a dialogue loaded, to communicate with the main character
@export var dialogue_resource: DialogueResource
# Dialogue start definition
@export var dialogue_start: String = "start"
# Dialogue template definition
@export var Balloon: PackedScene
# NPC area definition
@export var area: Area2D
# NPC exit area definition
@export var area_listen: Area2D
# Main character definition
@export var npc: CharacterBody2D
# Optionally, the dialogue can be initiated with a keyboard event
@export var show_input_key: String = ""
# To know if the NPC is the "BigGuy"
@export var is_big_guy: bool = false

# We define the main character node
var character: Node2D
# Indicates whether the dialogue is being displayed or not
var _dialogue_is_visible = false
# Indicates if we are in the dialogue area
var _in_dialogue = false

# Initialization function
func _ready():
	# Dialogue initialization
	talk.connect(_show_dialogue)
	area.body_entered.connect(_body_entered)
	if !area_listen:
		area_listen = area
	area_listen.body_exited.connect(_body_exited)


func _unhandled_input(event):
	if event.is_action_pressed(show_input_key) and character and not _dialogue_is_visible:
		# If we press the key defined in "show_input_key" and it is not currently being displayed
         	# we show the dialogue
         	# Also, the "character" variable must exist, as it indicates that the
         	# main character is in the NPC's area
		_show_dialogue()

# We set a new dialogue and show it
func set_and_show_dialogue(resource: DialogueResource):
	set_dialogue(resource)
	_show_dialogue()


# We set a new dialogue
func set_dialogue(resource: DialogueResource):
	dialogue_resource = resource


# We show the dialogue
func _show_dialogue():
	if _in_dialogue:
		return
	# Dialogue template initialization
	var balloon: Node = (Balloon).instantiate()
	# Add the initialized code to the scene
	get_tree().current_scene.add_child(balloon)
	# Open dialogue
	balloon.start(dialogue_resource, dialogue_start)

	# We listen when the dialogue ends
	balloon.on_dialogue_ended(_npc_dialogue_ended)
	balloon.on_response_selected(_on_response_selected)
	# We disable the main character
	character.set_disabled(true)
	character.set_idle()
	_dialogue_is_visible = true
	_in_dialogue = true


# The dialogue ended signal is emitted
func _npc_dialogue_ended():
	self.emit_signal("dialogue_ended")
	# We enable the main character
	character.set_disabled(false)
	_dialogue_is_visible = false


# The signal is emitted when a dialogue response is selected
func _on_response_selected(response: String):
	self.emit_signal("response_selected", response)


# We add an event to listen when the dialogue ends
func on_dialogue_ended(fn):
	dialogue_ended.connect(fn)


# We add an event to listen when a dialogue response is selected
func on_response_selected(fn):
	response_selected.connect(fn)


# We detect when a "body" comes into contact with the NPC
func _body_entered(body):
	# We validate if the collision is with the main character
	if body.is_in_group("player"):
		# We access the script
		character = body.get_node("MainCharacterMovement")
		# We show the dialogue (only if we don't have a "key" to activate it)
		if show_input_key == "":
			_show_dialogue()
		# We search for the animation node
		var _npc_animation: AnimatedSprite2D = npc.find_child('Npc')
		# We flip the character to look left or right
		if body.global_position.x > area.global_position.x:
			_npc_animation.flip_h = false
			if is_big_guy:
				_npc_animation.flip_h = true
		else:
			_npc_animation.flip_h = true
			if is_big_guy:
				_npc_animation.flip_h = false


# We detect when a "body" exits the NPC
func _body_exited(_body):
	character = null
	_in_dialogue = false
