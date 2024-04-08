extends Node2D
## Main menu script.
##
## It will control access to the main menu and its actions (start, full screen, and sound volume)
## Main menu: https://docs.google.com/document/d/17z6OpRIyuTMBbdYGBseTlv9aqLGkM_OUsWnzCGrWyJs/edit?usp=sharing
## Full screen and start game: https://docs.google.com/document/d/1iXAeyJgSInJz_jI_zl1tHWvQ12DSI-W2FpcLWdxGre8/edit?usp=sharing
## Sound control: https://docs.google.com/document/d/1iF9UeO_rtx2qWtMxjB6LienO-kQPx3blTCgJw-aACx4/edit?usp=sharing

# Initial level that will be loaded when pressing "Start" in the main menu
const PATH_LEVEL_1 = "res://scenes/game/levels/rooms/scene_1/scene_1.tscn"


# Variables for cloud animation
var _parallax_1_normal = true
var _parallax_2_normal = false
var _started = false # Indica si ya iniciamos el juego (entramos al primer nivel)

# References to scene nodes
@onready var _anim_water = $Main/World/Background/AnimWater
@onready var _anim_ship = $Main/World/Ship/Ship
@onready var _anim_flag = $Main/World/Ship/Flag
@onready var _parallax_1 = $Main/ParallaxBackground/Parallax1
@onready var _parallax_2 = $Main/ParallaxBackground/Parallax2
@onready var _button = $Main/CanvasLayer/Options/Init/Button/Button
@onready var _slider_ambient = $Main/CanvasLayer/Options/Sounds/Sliders/Ambient/Slider/SliderAmbient
@onready var _slider_effects = $Main/CanvasLayer/Options/Sounds/Sliders/Effects/Slider/SliderEffects
@onready var _main = $Main
@onready var _game_controls = $Main/GameControls


# Initialization function
func _ready():
	# When loaded, make this scene invisible
	visible = true
	# Prevent this scene from being paused
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	#_toggle_show()
	HealthDashboard.visible = false
	# Start animations
	_anim_water.play()
	_anim_ship.play()
	_anim_flag.play()
	_parallax_1.play("parallax1")
	_parallax_2.play_backwards("parallax1")
	# Initialize sound volume based on the value of the "sliders"
	_on_slider_ambient_value_changed(_slider_ambient.value)
	_on_slider_effects_value_changed(_slider_effects.value)
	_toggle_show()
	# Hide the controls canvas
	_game_controls.visible = false

# Detects keyboard and mouse events
func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and _started:
		# When pressing "escape", show/hide the menu (only if we have "started")
		_toggle_show()


# Executes when the animation of clouds #1 finishes
func _on_parallax_1_animation_finished(_anim_name):
	# Makes the animation go from left to right indefinitely
	if _parallax_1_normal:
		_parallax_1.play_backwards("parallax1")
		_parallax_1_normal = false
	else:
		_parallax_1.play("parallax1")
		_parallax_1_normal = true


# Executes when the animation of clouds #2 finishes
func _on_parallax_2_animation_finished(_anim_name):
	# Makes the animation go from left to right indefinitely
	if _parallax_2_normal:
		_parallax_2.play_backwards("parallax1")
		_parallax_2_normal = false
	else:
		_parallax_2.play("parallax1")
		_parallax_2_normal = true


# Function that will show or hide the main menu, unmounting nodes, pausing, and controlling
# cameras of the levels
func _toggle_show():
	visible = not visible # Show/Hide the menu
	HealthDashboard.visible = not visible # Show/Hide the health dashboard
	# Add or remove the main node of the main menu
	if visible:
		self.add_child(_main)
	else:
		self.remove_child(_main)
	
	get_tree().paused = visible # Si estamos en el menú, pausamos
	
	# Look for the main node of the current level "Main"
	var main_node = get_tree().get_root().get_node("Main")
	if main_node:
		# Look for the camera of the current level "Camera2D"
		var camera = main_node.find_child("Camera2D")
		if camera:
			# Enable or disable the camera
			camera.enabled = not visible
	# If we have already started, change the button text to "Continue"
	if _started:
		_button.text = "Continuar"


 # Event of the "CheckButton" node to toggle fullscreen or windowed mode
func _on_check_button_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Executes when the "start" button is pressed
func _on_button_pressed():
	if _started:
		# If the game has already started, just hide the menu
		_toggle_show()
	else:
		# If we haven't started, load level 1 and change the button title
		SceneTransition.change_scene(PATH_LEVEL_1)
		_started = true
		#_toggle_show()


# When the ambient sound slider changes, adjust the ambient volume
func _on_slider_ambient_value_changed(value):
	var bus = AudioServer.get_bus_index("Ambient")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))


# When the effects sound slider changes, adjust the effects volume
func _on_slider_effects_value_changed(value):
	var bus = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))


# Function to show/hide the menu
func show_menu(_show: bool):
	if _show:
		if not visible:
			_toggle_show()
	else:
		if visible:
			_toggle_show()


# Function to restart the game
func restart():
	#_toggle_show()
	_started = false
	_button.text = "Iniciar"


# Show/Hide the controls screen
func _on_show_controls_pressed():
	_game_controls.visible = not _game_controls.visible


# Close the controls screen
func _on_close_controls_pressed():
	_game_controls.visible = false
