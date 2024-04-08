extends Node
## Script for spike damage object
##
## Upon contact with this object, the character loses all life


var _player_script: Node2D # Reference to the player script, to reduce life

@onready var _timer = $Timer # Variable for timing the damage


# Listen for when a body enters the contact area
func _on_area_body_entered(body):
	if body.is_in_group("player"):
		_player_script = body.get_node("MainCharacterMovement")
		# "Hit" the character
		_player_script.hit(2)
		# Start the timer
		_timer.start()


# Listen for when a body exits the contact area
func _on_area_body_exited(body):
	# When leaving the spikes, clear the variable to stop causing damage
	_player_script = null


# Listen for when the timer ends
func _on_timer_timeout():
	# If the player script is not active, exit the function
	if not _player_script:
		return
	# If the player has no more life, exit the function
	if HealthDashboard.life <= 0:
		return
	# When the timer ends, damage the player
	_player_script.hit(2)
	# Then restart the timer
	_timer.start()
