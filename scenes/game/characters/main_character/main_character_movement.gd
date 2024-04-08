extends Node2D
## Movement and animation controller for a character.
##
## Detects keyboard events to move a character around a scene
## and adjust animations according to movement
## Basic character movement: https://docs.google.com/document/d/1c9XXznR1KBJSr0jrEWjYIqfFuNGCGP2YASkXsFgEayU/edit
 

@export var character: CharacterBody2D # Referencia al personaje a mover
@export var main_animation: AnimatedSprite2D # Referencia al sprite del personaje
@export var effect_animation_sword: AnimatedSprite2D # Referencia al sprite del personaje
@export var audio_player: AudioStreamPlayer2D # Reproductor de audios
@onready var _collision := $"../AreaSword/CollisionShape2D" # Colicionador de espada
@onready var _effect_sword := $"../EffectsSword" # Efectos de espada

var gravity = 650 # Gravedad para el personaje
var velocity = 100 # Velocidad de movimiento en horizontal
var jump = 220 # Capacidad de salto, entre mayor el número más se puede saltar
# Character movement map
var _movements = {
	IDLE = "default",
	IDLE_WITH_SWORD = "idle_with_sword",
	LEFT_WITH_SWORD = "left_with_sword",
	RIGHT_WITH_SWORD = "run_with_sword",
	JUMP_WITH_SWORD = "jump_with_sword",
	FALL_WITH_SWORD = "fall_with_sword",
	HIT_WITH_SWORD = "hit_with_sword",
	DEAD_HIT = "dead_hit",
	ATTACK = "attack_2",
	BOMB = "attack_3",
}
var _current_movement = _movements.IDLE # Variable de movimiento
var _is_jumping = false # Indicamos que el personaje está saltando
var _max_jumps = 2 # Máximo número de saltos
var _jump_count = 0 # Contador de saltos realizados
var _died = false # Define si esta vovo o muerto
var attacking = false # Define si esta atacando
var bombing = false # Define si esta atacando
var _is_playing: String = "" # Define si se esta reproducionedo el sonido
var turn_side: String = "right" # Define si se esta reproducionedo el sonido

# We preload the jump sounds
var _jump_sound = preload("res://assets/sounds/jump.mp3")
var _run_sound = preload("res://assets/sounds/running.mp3")
var _dead_sound = preload("res://assets/sounds/dead.mp3")
var _male_hurt_sound = preload("res://assets/sounds/male_hurt.mp3")
var _hit_sound = preload("res://assets/sounds/slash.mp3")


# Initialization function
func _ready():
	main_animation.play(_current_movement)
	# If there is no character, we disable the _physics_process function
	if not character:
		set_physics_process(false)


# Physics execution function
func _physics_process(_delta):
	_move(_delta)
	

func _unhandled_input(event):
	# When the x key is pressed, we attack	
	if event.is_action_released("hit"):
		character.velocity.x = 0
		_current_movement = _movements.ATTACK
	# When the b key is pressed, we throw a bomb
	elif event.is_action_released("bomb"):
		_current_movement = _movements.BOMB
	_set_animation()


# General movement function of the character
func _move(delta):
	# When the left arrow key is pressed, we move the character to the left
	if Input.is_action_pressed("izquierda"):
		character.velocity.x = -velocity
		_current_movement = _movements.LEFT_WITH_SWORD	
		turn_side = "left"
	# When the right arrow key is pressed, we move the character to the right
	elif Input.is_action_pressed("derecha"):
		character.velocity.x = velocity
		_current_movement = _movements.RIGHT_WITH_SWORD
		turn_side = "right"
	# When no keys are pressed, there is no movement	
	else:
		character.velocity.x = 0
		_current_movement = _movements.IDLE	
	
	# When the space key is pressed, we do the jump animation
	if Input.is_action_just_pressed("saltar"):
		if character.is_on_floor():
			_current_movement = _movements.JUMP_WITH_SWORD
			_is_jumping = true
			_jump_count += 1 # Sumamos el primer salto
		elif _is_jumping and _jump_count < _max_jumps:
			_current_movement = _movements.JUMP_WITH_SWORD
			_jump_count += 1 # Sumamos el segundo salto

	_apply_gravity(delta)
	
	if _died: # If the character died, it cannot move on the X axis
		character.velocity.x = 0
	
	_set_animation()
	# Godot function to move and apply physics and collisions
	character.move_and_slide()


# Controls the animation according to the character's movement
func _set_animation():
	# If it's attacking, we don't interrupt the animation
	if attacking or bombing:
		return
	# If the character died
	if _died:
		main_animation.play(_movements.DEAD_HIT)
		return
	if _is_jumping:	
		# Jump movement (jump animation)
		if character.velocity.y >= 0:
			# We are falling
			main_animation.play(_movements.FALL_WITH_SWORD)
		else:
			# We are ascending
			main_animation.play(_movements.JUMP_WITH_SWORD)
	elif _current_movement == _movements.ATTACK:
		# We attack
		attacking = true
		main_animation.play(_movements.ATTACK)
		_play_sound(_hit_sound)
		# We add the special effect
		_play_sword_effect()
	elif _current_movement == _movements.BOMB:
		# We throw a bomb
		bombing = true
		main_animation.play(_movements.BOMB)
	elif _current_movement == _movements.RIGHT_WITH_SWORD:
		# Movement to the right (unflipped "run" animation)
		main_animation.play(_movements.RIGHT_WITH_SWORD)
		main_animation.flip_h = false
		_collision.position.x = abs(_collision.position.x)
		_effect_sword.position.x = abs(_effect_sword.position.x)
		_effect_sword.scale.x = abs(_effect_sword.scale.x)
	elif _current_movement == _movements.LEFT_WITH_SWORD:
		# Movement to the left (flipped "run" animation)
		main_animation.play(_movements.RIGHT_WITH_SWORD)
		main_animation.flip_h = true
		_collision.position.x = - abs(_collision.position.x)
		_effect_sword.position.x = - abs(_effect_sword.position.x)
		_effect_sword.scale.x = - abs(_effect_sword.scale.x)
	else:
		# Default movement (idle animation)
		main_animation.play(_movements.IDLE_WITH_SWORD)
		# We pause the sound
		audio_player.stop()
		_is_playing = ""


# Function that applies gravity for falling or jumping
func _apply_gravity(delta):
	var v = character.velocity
	
	# The jump is executed only once, at that moment we make the character jump
	if _current_movement == _movements.JUMP_WITH_SWORD and not _died:
		# We jump, only if the character has not died
		v.y = -jump
	else:
		# Application of gravity (acceleration in the fall)
		v.y += gravity * delta
		# After a jump, we validate when we touch the ground again to be able to jump again
		if character.is_on_floor():
			# We reset jump variables
			_is_jumping = false
			_jump_count = 0
	# We apply the velocity vector to the character
	character.velocity = v
	
func die():
	# We set the die variable to true
	_died = true


# Receiving damage
func hit(value: int):
	if _died:
		return
	attacking = false
	HealthDashboard.remove_life(value)
	_play_sound(_male_hurt_sound)
	main_animation.play("hit_with_sword")
	
	# We decrease life and validate if the character has lost
	if HealthDashboard.life == 0:
		_died = true
	else:
		pass
		# Hit animation


func _on_animation_animation_finished():
	# We validate if the animation is of dying
	if main_animation.get_animation() == 'dead_hit':
		# We validate if the sound is already playing
		if _is_playing != "_dead_sound":
			_is_playing = "_dead_sound"
			# We play the sound
			_play_sound(_dead_sound)
	elif main_animation.get_animation() == _movements.ATTACK:
		attacking = false
	elif main_animation.get_animation() == _movements.BOMB:
		bombing = false


func _on_animation_frame_changed():	
	# If the animation is of attacking we enable the collider
	if main_animation.animation == "attack_2" and main_animation.frame == 1:
		_collision.set_deferred("disabled", false)
	else:
		# If the animation is not of attacking we disable the collider
		_collision.set_deferred("disabled", true)
		
	if main_animation.animation == _movements.JUMP_WITH_SWORD:
		# We validate if the sound is already playing
		if _is_playing != "_jump_sound":
			_is_playing = "_jump_sound"
			# We play the sound
			_play_sound(_jump_sound)
	if (
		main_animation.animation == _movements.RIGHT_WITH_SWORD 
		or main_animation.animation == _movements.LEFT_WITH_SWORD 
	):
		# We validate if the sound is already playing
		if _is_playing != "_run_sound":
			_is_playing = "_run_sound"
			# We play the sound
			_play_sound(_run_sound)


func _on_audio_stream_player_2d_finished():
	if audio_player.stream == _dead_sound:
		# We remove the main character from the scene
		self.get_parent().queue_free()
		# We restart the game after 2 seconds
		SceneTransition.reload_scene()
		
		
func _play_sound(sound):
	# We pause the sound
	audio_player.stop()
	# We play the sound
	audio_player.stream = sound
	audio_player.play()
	
func set_disabled(disabled: bool):
	set_physics_process(not disabled)
	
func set_idle():
	# Default movement (idle animation)
	main_animation.play(_movements.IDLE_WITH_SWORD)
	# We pause the sound
	audio_player.stop()
	
func _play_sword_effect():
	# We get which effect we have active
	var type = Global.attack_effect
	if type == "blue_potion":
		# We apply the blue_potion effect
		effect_animation_sword.self_modulate = Color("#70a2ff")
	elif type == "green_bottle":
		# We apply the green_bottle effect
		effect_animation_sword.self_modulate = Color("#80b65a")
	else:
		# We apply the predefined effect
		effect_animation_sword.self_modulate = Color("#ffffff")
	
	# We play the sword effect
	effect_animation_sword.play("attack_2_effect")
