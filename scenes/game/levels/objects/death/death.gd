extends Area2D
## Class that removes life from the main character
##
## Removes life from the main character


func _on_body_entered(body):
	if body.is_in_group("player"):
		# Remove life
		var _move_script = body.get_node("MainCharacterMovement")
		_move_script.hit(100)
