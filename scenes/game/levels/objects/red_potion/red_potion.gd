extends Node2D
## Health recovery object
##
## Handles animations, collision detection, and adds life to the main character


# Amount of life to recover
@export var life = 4

# Animation and audio variables for the potion
@onready var _potion = $Potion
@onready var _effect = $Effect
@onready var _audio = $AudioStreamPlayer


# Initialization function
func _ready():
	_potion.play() # Start with the object's animation


# Detect bodies entering the potion's area
func _on_area_body_entered(body):
	if body.is_in_group("player"):
		# If the player enters, add life and free memory
		HealthDashboard.add_life(life)
		_audio.play()
		_potion.visible = false
		_effect.visible = true
		# Before freeing memory, animate the potion being picked up
		_effect.play()
		await _effect.animation_finished
		self.queue_free() # Free memory
