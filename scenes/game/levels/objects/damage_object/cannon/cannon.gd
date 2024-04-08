extends RigidBody2D
## Class that controls the animation and configuration of the cannon object
##
## Sets the animation of the object
## Changes animation from idle to fired, removes the bullet from the scene


# Define the destruction scene of the object
@onready var _cannon_animation = $AnimatedSprite2D
# Define the animated sprite effects
@onready var _animated_sprite_effects = $AnimatedSprite2DEffects
# Define the cannonball
var new_ball: RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Fire the cannon
	fire()
	
	
func fire():
	# Play the firing animation
	_cannon_animation.play("fire")


func _on_animated_sprite_2d_frame_changed():
	# Check if the animation frame is 3
	if _cannon_animation.frame == 3:
		# Load the cannonball scene
		var ball = "scenes/game/levels/objects/damage_object/cannon/cannon_ball.tscn"
		new_ball = load(ball).instantiate()
		new_ball.position.x = -20
		# Add the cannonball to the scene
		self.add_child(new_ball)
		# Play the fire effect animation
		_animated_sprite_effects.play("fire_effect")


func _on_animated_sprite_2d_animation_finished():
	# Check if the animation is 'fire'
	if _cannon_animation.get_animation() == 'fire':
		# Wait for one second
		await get_tree().create_timer(1).timeout
		# Remove the cannonball
		new_ball.queue_free()
		# Fire again
		fire()
		
