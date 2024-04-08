extends CharacterBody2D
## Class that controls animation and configuration of the Enemy
##
## Sets the animation and behavior of the Enemy



# Actions of the enemy
@export_enum(
	"idle",
	"run",
) var animation: String

# Movement direction of the Enemy
@export_enum(
	"left",
	"right",
	"active",
) var moving_direction: String

# Variable for animation and collision control
@onready var _animation := $EnemyAnimation
@onready var _animation_effect := $EnemyEffect
@onready var _raycast_terrain := $Area2D/RayCastTerrain
@onready var _raycast_wall := $Area2D/RayCastWall
@onready var _raycast_vision_left := $Area2D/RayCastVisionLeft
@onready var _raycast_vision_right := $Area2D/RayCastVisionRight
@onready var _audio_player= $AudioStreamPlayer2D # Reproductor de audios

# Define sounds
var _punch_sound = preload("res://assets/sounds/punch.mp3")
var _male_hurt_sound = preload("res://assets/sounds/male_hurt.mp3")

# Define physics parameters
var _gravity = 10
var _speed = 25
# Define movement direction
var _moving_left = true
# Copy of object that enters collision
var _body: Node2D
# Pursuit flag
var _is_persecuted = false
# Flag for not detecting collisions
var _stop_detection = false
# Flag for not detecting attacks
var _stop_attack = false
# How many hits it can take
var _hit_to_die = 3
# How many times the main character has hit
var _has_hits = 0
# Crab's death
var die = false


# Initialization function
func _ready():
	# Set the movement direction
	if moving_direction == 'right':
		_moving_left = false
		scale.x = -scale.x
	# If animation is not set, default to idle animation
	if not animation:
		animation = "idle"
	# Start the animation
	_init_state()


func _physics_process(delta):
	if (die): return
	# If the animation is running, apply movement
	if animation == "run":
		_move_character(delta)
		_turn()
	# If the animation is idle, apply idle movement
	elif animation == "idle":
		_move_idle()
	# If the animation is pursuit, apply pursuit
	if moving_direction == "active" and !_stop_detection:
		_detection()


func _move_character(_delta):
	# Aplicamos la gravidad
	velocity.y += _gravity
	
	# Aplicamos la dirección de movimiento
	if _moving_left:
		velocity.x = - _speed
	else:
		velocity.x = _speed

	# Iniciamos el movimiento
	move_and_slide()


func _move_idle():
	# Apply gravity
	velocity.y += _gravity
	# Apply movement direction
	velocity.x = 0
	# Start movement
	move_and_slide()


func _on_area_2d_body_entered(body):
	# Check if the collision is with the main character
	if body.is_in_group("player"):
		_stop_detection = true
		# Attack
		_attack()
		# Create object copy
		_body = body


func _on_area_2d_body_exited(__body):
	if not die:
		# Initiate state
		_init_state()


func _turn():
	# Check if the terrain has ended
	if not _raycast_terrain.is_colliding() or _raycast_wall.is_colliding():
		var _object = _raycast_wall.get_collider()
		if not _object or _object and not _object.is_in_group("player"):
			# Turn around
			_moving_left = !_moving_left
			scale.x = -scale.x


func _attack():	
	# Do not attack if _stop_attack flag is set
	if _stop_attack:
		return
		
	if not _body:
		# Wait for 1 second
		await get_tree().create_timer(0).timeout
		_attack()
		
	# Attack animation
	_animation.play("attack")


func _init_state():
	if _stop_attack:
		return
	# Initial state animation
	velocity.x = 0
	_animation.play(animation)
	_animation_effect.play("idle")
	# Clear variables
	_body = null
	_stop_detection = false

func _on_enemy_animation_frame_changed():
	if _stop_attack:
		return
	# Check if the animation frame is 0
	if _animation.frame == 0 and _animation.get_animation() == "attack":
		# Hit the character
		_animation_effect.play("attack_effect")
		
		if HealthDashboard.life > 0:
			# Play sound
			_audio_player.stream = _male_hurt_sound
			_audio_player.play()
		else:
			_animation.play("idle")
			_animation_effect.play("idle")
		
		if _body:
			# Remove lives
			var _move_script = _body.get_node("MainCharacterMovement")
			_move_script.hit(2)


func _detection():
	# If there is no ground, return to initial state
	if not _raycast_terrain.is_colliding():
		# Start animation
		_init_state()
		return
	# Get colliders
	var _object1 = _raycast_vision_left.get_collider()
	var _object2 = _raycast_vision_right.get_collider()
	
	# Check if the collision is on the left side
	if _object1 and _object1.is_in_group("player") and _raycast_vision_left.is_colliding():
		_move(true)
	else:
		_is_persecuted = false
	
	# Check if the collision is on the right side
	if _object2 and _object2.is_in_group("player") and _raycast_vision_right.is_colliding():
		_move(false)
	
	# No collisions
	if not _object1 and not _object2 and _animation.get_animation() != "attack":
		_is_persecuted = false
		
		
func _move(_direction):
	# If we are already in action, exit
	if _is_persecuted or _animation.get_animation() == "attack":
		return
	# Apply gravity
	velocity.y += _gravity
	
	# Turn the character
	if not _direction:
		_moving_left = !_moving_left
		scale.x = -scale.x
	else:
		# Apply movement direction
		if _moving_left:
			velocity.x = - _speed * 5
		else:
			velocity.x = _speed * 5

	# Start movement
	move_and_slide()


func _on_area_2d_area_entered(area):
	# If the enemy is being attacked
	if area.is_in_group("hit"):
		_damage()
	elif area.is_in_group("die"):
		die = true
		_damage()

func _damage():	
	# Add a hit
	_has_hits += 1
	# Play sound
	_audio_player.stream = _punch_sound
	_audio_player.play()
	# Play hit animation
	_animation.play("hit")
	_animation_effect.play("idle")
	
	# Check if we have a special attack
	if Global.number_attack > 0:
		# Subtract 1 from the special attack
		die = true
		Global.number_attack -= 1
	
	# Check if we no longer have an attack
	if Global.number_attack == 0:
		# Set the normal attack
		Global.attack_effect = "normal"

	if die or _hit_to_die <= _has_hits:
		# Set flag not to attack
		_stop_attack = true
		die = true
		velocity.x = 0
		# Kill it and remove from the scene
		if _animation.animation != "dead_ground":
			_animation.play("dead_ground")


func _on_enemy_animation_animation_finished():
	if _animation.animation == "dead_ground":
		queue_free()
	elif _animation.animation == "hit":
		if not _stop_attack: 
			_animation.play("idle")
			_animation_effect.play("idle")
			# Attack
			_attack()
	
