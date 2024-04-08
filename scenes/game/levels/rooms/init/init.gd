extends Node2D
## Class that controls the initial scene
## 
## Displays the main menu turned off from the Splash scene


# Called when the node enters the scene tree for the first time.
func _ready():
	# Show the main menu
	MainMenu.show_menu(true)

