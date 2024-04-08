extends RigidBody2D
## Class that controls bomb animation and configuration
##
## Sets the explosion animation


# Preload the bomb scene
var _bomb_effect = preload("res://scenes/game/levels/objects/damage_object/bomb/bomb_explotion.tscn")

# Define the animation node
@onready var _animation = $BombAnimation

# Called when the node enters the scene tree for the first time.
func _ready():
	# Wait 3 seconds for the explosion
	await get_tree().create_timer(3).timeout
	# Remove the bomb
	_animation.play("idle")
	# Get the last position
	var _pos = position
	# Get the explosion scene
	var bomb_scene = _bomb_effect.instantiate()
	# Adjust positions
	bomb_scene.position = _pos
	bomb_scene.position.y = _pos.y - 20
	# Add the effect to the scene
	get_parent().add_child(bomb_scene)
	queue_free()
