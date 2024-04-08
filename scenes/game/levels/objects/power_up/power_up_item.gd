extends Node2D
## Inventory item script
##
## This object, when used, will show an informative dialogue
## Item creation: https://docs.google.com/document/d/1XY3Y5Q1njEV8fwL3x4ogLF6Nyz01gobjJ7mr_Vh-jPE/edit?usp=sharing
## Item usage: https://docs.google.com/document/d/1zjo0Deoc_yy-wdmGRd9rvUbNIDHhNxRlmNxb8qhc5Xg/edit?usp=sharing


var _is_active = false # Para saber si el puntero está en el item
# Animation and dialogues mapping
var _dialogues = {
	"blue_potion": "res://scenes/game/dialogues/dialogues/power_up/blue_potion_item.dialogue",
	"green_bottle": "res://scenes/game/dialogues/dialogues/power_up/green_bottle_item.dialogue",
}

@export var num = "1" # Count number
@onready var canvas = $Num # Counter
@onready var animation = $PowerUpItem # Animation
@onready var _confirm = $CanvasConfirm # Confirmation dialogue


# Initialization function
func _ready():
	canvas.text = num


# Function to detect keyboard and mouse events
func _unhandled_input(event):
	if not _is_active:
		return # If the pointer is not over the item, end the function
	# If we click, show the confirmation dialogue
	if event is InputEventMouseButton and event.is_action_released("clic"):
		_confirm.show()


# Show the dialogue
func _show_dialogue():
	var _resource = _dialogues[animation.animation]
	var _instance = load(_resource)
	var _dialogue = CustomDialogue.create_and_show_dialogue(_instance)
	_dialogue.on_dialogue_ended(_on_dialogue_ended)


# Listen for when the dialogue ends
func _on_dialogue_ended():
	# Remove the item from the inventory
	InventoryCanvas.remove_item_by_name(animation.animation)

# Update the available quantity
func set_num(_num: String):
	canvas.text = _num


# Get the available quantity
func get_num():
	return int(canvas.text)


# Listen for when the pointer enters the item
func _on_area_mouse_entered():
	_is_active = true


# Listen for when the pointer leaves the item
func _on_area_mouse_exited():
	_is_active = false


# When the "cancel" button is pressed
func _on_cancel_pressed():
	_confirm.hide()


# When the "accept" button is pressed
func _on_accept_pressed():
	# Activate the power
	Global.attack_effect = animation.animation
	Global.number_attack = 4
	_confirm.hide()
	InventoryCanvas.show_inventory(false)
	_show_dialogue()


# Get the object name
func set_animation(animation_name):
	animation.play(animation_name)
