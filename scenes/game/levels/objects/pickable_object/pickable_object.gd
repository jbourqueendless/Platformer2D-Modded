extends Area2D
## Class that controls animation and configuration of collectible objects
##
## Sets the animation of the object according to the configured name
## Changes animation from idle to collected, removes collected object from the scene


# Name of the main character
@export_enum(
	"blue_diamond",
	"green_diamond", 
	"red_diamond",
	"gold_coin",
	"silver_coin",
) var animation: String

# Define the animated sprite of the coin
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _audio_player= $AudioStreamPlayer2D # Reproductor de audios

var _pickup_sound = preload("res://assets/sounds/pickup.mp3")


# Function to load the node
func _ready():
	if not animation:
		return
	
	# Load animation textures according to the configured name
	var _animation1 = "res://assets/sprites/treasure_hunters/pirate_treasure/sprites/" + animation + "/01.png"
	var _animation2 = "res://assets/sprites/treasure_hunters/pirate_treasure/sprites/" + animation + "/02.png"
	var _animation3 = "res://assets/sprites/treasure_hunters/pirate_treasure/sprites/" + animation + "/03.png"
	var _animation4 = "res://assets/sprites/treasure_hunters/pirate_treasure/sprites/" + animation + "/04.png"

	# Apply the loaded texture to the animation
	_animated_sprite.sprite_frames.set_frame("idle", 0, load(_animation1))
	_animated_sprite.sprite_frames.set_frame("idle", 1, load(_animation2))
	_animated_sprite.sprite_frames.set_frame("idle", 2, load(_animation3))
	_animated_sprite.sprite_frames.set_frame("idle", 3, load(_animation4))
	
	# Play idle animation
	_animated_sprite.play("idle")
	

func _on_animated_sprite_2d_animation_finished():
	# Wait for 2 seconds  
	await get_tree().create_timer(2).timeout
	# Remove the collected object from the scene
	queue_free()
	
	
func do_animation():
	# Check if the animation is for a coin
	_audio_player.stream = _pickup_sound
	_audio_player.play()
	if animation == "gold_coin" or animation == "silver_coin":
		# Play the coin animation
		_animated_sprite.play("coin_taken")
	else:
		# Play the diamond animation
		_animated_sprite.play("diamond_taken")
		
	# Add the collected objects
	var type = "GoldCoin"
	if animation == "silver_coin":
		type = "SilverCoin"
	elif animation == "blue_diamond":
		type = "BlueDiamond"
	elif animation == "green_diamond":
		type = "GreenDiamond"
	elif animation == "red_diamond":
		type = "RedDiamond"
	# All different types of objects add 1 unit
	HealthDashboard.add_points(type, 1) 


func _on_area_entered(area):
	# Check if the collision is with the main character 
	if area.is_in_group("player"):
		# Play the animation of the collected coin
		do_animation()


func _on_body_entered(body):
	# Check if the collision is with the main character
	if body.is_in_group("player"):
		# Play the animation of the collected coin
		do_animation()
