extends Node2D
## Bomb throwing controller.
##
## Listens to the bomb throw key and throws the bomb.


# We preload the bomb scene
var _bomb = preload("res://scenes/game/levels/objects/damage_object/bomb/bomb.tscn")
# The movement script
var _move_script: Node2D


func _ready():
	HealthDashboard.add_bomb(2)
	_move_script = get_parent().get_node("MainCharacterMovement")


# Called when the node enters the scene tree for the first time.
func _unhandled_input(event):
	#  We validate how many bombs we have
	var _count_bomb = HealthDashboard.points["Bomb"]
	# When the key (B - bomb) is pressed and we did not throw the bomb before
	if event.is_action_released("bomb") and not _move_script.bombing and _count_bomb > 0:
		# We remove the bomb from the inventory
		HealthDashboard.add_bomb(-1)
		# We initialize the bomb
		var bomb_scene = _bomb.instantiate()
		# We set the position next to the main character
		var _character = get_parent()
		var _character_position = _character.position
		bomb_scene.position = _character_position
		# We set the direction of the force and offset
		if _move_script.turn_side == "right":
			bomb_scene.linear_velocity.x = abs(bomb_scene.linear_velocity.x)
			bomb_scene.position.x = _character_position.x + 25
		else:
			bomb_scene.linear_velocity.x = - abs(bomb_scene.linear_velocity.x)
			bomb_scene.position.x = _character_position.x - 25
	
		# We add the bomb to the scene
		get_parent().get_parent().add_child(bomb_scene)
