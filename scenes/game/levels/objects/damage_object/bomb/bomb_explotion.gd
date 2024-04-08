extends AnimatedSprite2D
## Class that controls the explosion
##
## Removes the scene after explosion, deals damage


@onready var _collision := $Area2D/DamageCollision # Colicionador de la bomba


func _on_audio_stream_player_finished():
	# Remove the scene
	queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		# Remove lives
		var _move_script = body.get_node("MainCharacterMovement")
		_move_script.hit(10)


func _on_frame_changed():
	# If the frame is 1, enable the collision detector
	if frame == 1:
		_collision.disabled = false
	else:
		# Disable the collision detector
		_collision.disabled = true
