extends Node2D
## Class that controls the main scene (Splash)
## 
## Changes the current scene to the global map of the game, animates logos, game owners 


@onready var AnimationPlayerGP360: AnimationPlayer = $AnimationPlayerGP360
@onready var AnimationPlayerEndless: AnimationPlayer = $AnimationPlayerEndless
@onready var AnimationPixelFrog: AnimationPlayer = $AnimationPixelFrog

# Path to the scene to load when the "splash" is finished
var _path_map_scene = "res://scenes/game/levels/rooms/init/init.tscn"


func _ready():
	# Hide the menu scene
	HealthDashboard.visible = false
	# Show the Endless logo
	AnimationPlayerEndless.play("do_splash")


# Listen for keyboard input
func _input(event):
	# Listen if any button is pressed
	if event is InputEventKey:
		# Call the scene change function
		_go_title_screen()


# When the animation is finished
func _on_animation_player_animation_finished(_anim_name):
	# Mostramos el logo de Pixel Frog
	AnimationPixelFrog.play("do_splash")


# Redirect to the Map scene
func _go_title_screen():
	# Move to the main menu scene
	SceneTransition.change_scene(_path_map_scene)


func _on_animation_player_endless_animation_finished(anim_name):
	# Show the GP360 logo
	AnimationPlayerGP360.play("do_splash")


func _on_animation_pixel_frog_animation_finished(anim_name):
	# Call the scene change function
	_go_title_screen()
