extends CharacterBody2D
## Class that controls NPC behavior
##
## Controls dialogues with the main character, listens for collisions


# Contact area to display the dialogue
var _npc_dialogue_area: Node2D
# Determines the state of the dialogue (active or inactive)
var _dialog_active = false

@onready var _collision = $CollisionShape2D
@onready var _collisionListen = $Area2DListen/CollisionShape2D
@onready var _animation = $Npc

# Initialization function
func _ready():
	_npc_dialogue_area = find_child("NpcDialogueArea") # Buscamos el area de diálogo


func _physics_process(delta):
	# We add the velocity
	velocity.y += 1000 * delta
	move_and_slide() # Agregamos kinematica
	if is_on_floor():
		# We turn off the physics
		set_physics_process(false)
	

# DOCUMENTATION (signals): https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo/edit?usp=drive_link
# Used to "listen" when the dialogue ends
func on_dialogue_ended(fn):
	if _npc_dialogue_area:
		_npc_dialogue_area.on_dialogue_ended(fn)


# Used to "listen" when a response is selected in the dialogue
func on_response_selected(fn):
	if _npc_dialogue_area:
		_npc_dialogue_area.on_response_selected(fn)


# Function that disables NPC collisions and also physics
func disabled_collision(disabled: bool):
	set_physics_process(not disabled)
	_collision.disabled = disabled


# Function to flip the NPC animation
func flip_h(flip: bool):
	_animation.flip_h = flip


# We set a new dialogue and show it
func set_and_show_dialogue(resource: DialogueResource):
	if _npc_dialogue_area:
		_npc_dialogue_area.set_and_show_dialogue(resource)


# We set a new dialogue
func set_dialogue(resource: DialogueResource):
	if _npc_dialogue_area:
		_npc_dialogue_area.set_dialogue(resource)


# We return the active dialogue manager
func get_dialogue_manager():
	if _npc_dialogue_area:
		return _npc_dialogue_area.dialogue_manager


# DOCUMENTATION (collision areas): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link
# Function when an area comes into contact with the NPC. _area: is the area that makes contact
func _on_area_2d_listen_area_exited(area):
	# We set the dialogue variable to false when leaving the area
	_dialog_active = false
