extends RigidBody2D
## Class that controls animation and configuration of objects that take damage
##
## Sets the animation of the object according to the configured name
## Changes animation from idle to destroyed, removes destroyable object from the scene


# Define the animated sprite of the object
@onready var _animated_sprite = $AnimatedSprite2D
# Define the destruction scene of the object
@onready var _box_destroyed = $BoxDestroyed
# Flag for animating
var _do_animation = false

	
# Node initialization function
func _ready():
	# Start playing the idle animation
	_animated_sprite.play("idle")
	# Do not show the destruction animation
	_box_destroyed.get_parent().remove_child(_box_destroyed)
	

func _on_animated_sprite_2d_animation_finished():
	# Check if the animation is for hitting
	if _animated_sprite.get_animation() == 'hit':
		# Hide the box sprite
		_animated_sprite.visible = false
		# Remove collision
		self.set_deferred("collision_layer", 2)
		# Add the destruction animation
		self.add_child(_box_destroyed)
		# Wait for 3 seconds
		await get_tree().create_timer(3).timeout
		# Remove the object
		queue_free()
					
	
func do_animation():
	# Play the hit animation
	_animated_sprite.play("hit")


func _on_area_2d_area_entered(area):
	# Check for collision
	if area.is_in_group("hit"):
		_collided(area)
	elif area.is_in_group("die"):
		_collided(area)


func _collided(area):
	# Set the destruction direction
	if global_position.x < area.global_position.x:
		set_direction(false)
	else:
		set_direction(true)
		
	#  Check if we are already playing the animation
	if not _do_animation:
		# Set that we are now playing the animation
		_do_animation = true
		# Play the animation
		do_animation()
		
		
func set_direction(left):
	# Iterate over all children of the scene
	for child in _box_destroyed.get_children():
		# Store the defined speed
		var speed = abs(child.linear_velocity.x)
		if left:
			# Apply positive speed
			child.linear_velocity.x = speed
		else:
			# Apply negative speed
			child.linear_velocity.x = - speed
