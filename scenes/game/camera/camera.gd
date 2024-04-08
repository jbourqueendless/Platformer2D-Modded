extends Camera2D
## Main Camera for Scenes.
##
## Move the camera to follow the main character (using smooth motion)
## Camera Movement: https://docs.google.com/document/d/1kHbZN0nhy9GFL3zyO4tTZK4lqELZ3YDkbpxj6XVEkq8/edit?usp=sharing


# Reference to the main character
@export var character: CharacterBody2D


# Initialization function
func _ready():
	# If there is no character, we disable _physics_process and end the function
	if not character:
		set_physics_process(false)
		return
	# We set the initial position of the camera
	position = character.position


# Physics execution function
func _physics_process(delta):
	# We generate "interpolated" positions (between the camera's position and the character's)
	# to perform the camera movement
	# We validate if the character is alive and did not die
	if not character:
		# If the character is dead, we stop following it
		return
	var charpos = character.position
	var new_pos = position.lerp(charpos, delta * 2.0)
	# We adjust the values to whole numbers, to avoid moving the camera too many times
	new_pos.x = int(new_pos.x)
	new_pos.y = int(new_pos.y)
	# We set the new position of the camera
	position = new_pos
