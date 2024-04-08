extends AnimatedSprite2D
## Script for collectible objects with dialogues
##
## This object is stored in the inventory. It also shows an object information dialogue



# Animation and dialogues mapping
var _dialogues = {
	"blue_potion": "res://scenes/game/dialogues/dialogues/power_up/blue_potion.dialogue",
	"green_bottle": "res://scenes/game/dialogues/dialogues/power_up/green_bottle.dialogue",
}
var _move: Node2D # To disable the character


# Initialization function
func _ready():
	play()


# Show the dialogue
func _show_dialogue():
	var _resource = _dialogues[animation]
	var _instance = load(_resource)
	var _dialogue = CustomDialogue.create_and_show_dialogue(_instance)
	_dialogue.on_dialogue_ended(_on_dialogue_ended)


# Listen for when a "body" enters the object's area
func _on_area_body_entered(body):
	if body.is_in_group("player"):
		# If it's the "player," disable them and show the dialogue
		_show_dialogue()
		_move = body.get_node("MainCharacterMovement")
		_move.set_disabled(true)
		_move.set_idle()


# When picking up the object, play pick-up animation, and when finished, activate the character and free memory
func _pick_up():
	# Add items to the inventory
	InventoryCanvas.add_item_by_name(animation)
	# Play animation and remove the item from the scene
	play("pick_up")
	await animation_finished
	_move.set_disabled(false)
	queue_free()


# Listen for when the dialogue ends
func _on_dialogue_ended():
	_pick_up()
