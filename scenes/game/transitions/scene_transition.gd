extends CanvasLayer
## Scene changer with transition.
##
## It has a method to change from one scene to another using a transition
## Scene change: https://docs.google.com/document/d/1eIBtgr8wln1pT0aZ4c-YWk_pqngyBg4HDsgdYLAXv28/edit?usp=sharing


# Animation node
@onready var animation: AnimationPlayer = $AnimationPlayer


# Initialization function
func _ready():
	visible = false # At the start, the canvas should not be visible
	self.process_mode = Node.PROCESS_MODE_ALWAYS


 # Scene change function: target is the path to the scene to load
func change_scene(target: String, show_menu = false):
	# We show the canvas and display animation (from transparent to a color)
	visible = true
	animation.play("dissolve")
	# We wait for the animation to finish
	await animation.animation_finished
	# We hide the main menu
	MainMenu.show_menu(show_menu)
	# We load the scene
	get_tree().change_scene_to_file(target)
	# We display animation (from a color to transparent)
	animation.play_backwards("dissolve")
	# We wait for the animation to finish
	await animation.animation_finished
	animation.stop()
	# We hide the canvas again
	visible = false


# Function to restart the current scene
func reload_scene():
	HealthDashboard.visible = true
	HealthDashboard.restart()
	# We restart the scene
	get_tree().reload_current_scene()
