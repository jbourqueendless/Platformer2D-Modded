extends Node2D
## Collision controller.
##
## Detects collision events

@export var character: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if not character:
		set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# We check all collisions
	for i in character.get_slide_collision_count():
		# We get the collision
		var collision = character.get_slide_collision(i)
		# We get the collider
		var collider = collision.get_collider()
		# We validate if the hit method exists
		if collider and collider.has_method("hit"):
			collider.hit()
