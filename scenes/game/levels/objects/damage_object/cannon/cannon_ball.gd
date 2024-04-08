extends RigidBody2D
## Class that controls the bullet animation
##
## Sets the explosion animation

# Define the cannon animation
@onready var _ball_animation = $AnimatedSprite2D


func _on_body_entered(body):
	# Check if the collision is with the cannon
	if body.is_in_group("cannon"):
		return

	# Stop the bullet
	self.set_deferred("freeze", true)
	self.set_deferred("sleeping", true)
	self.set_deferred("linear_velocity.x", 0)
	self.set_deferred("linear_velocity.y", 0)
	self.set_deferred("gravity_scale", 0)
	self.collision_mask = 0
	self.collision_layer = 0
	# Play the explosion animation
	_ball_animation.play("explosion")
	if body.is_in_group("player"):
		# Remove the main character
		var _move_script = body.get_node("MainCharacterMovement")
		_move_script.hit(10)
