extends Node2D
## Main scene script.
##
## Contains variables and functions related to the scene, such as changes to other scenes
## Scene changes: https://docs.google.com/document/d/1eIBtgr8wln1pT0aZ4c-YWk_pqngyBg4HDsgdYLAXv28/edit?usp=sharing
## Use of signals: https://docs.google.com/document/d/1vFSOuJkBy7xr5jksgCBNaTpqJHE_K87ZNafB5ZJ_I0M/edit?usp=sharing


# Area for the next level
@onready var _area_next_level = $Areas/AreaNextLevel


# Initialization function
func _ready():
	# Listen for when the character enters the contact area
	_area_next_level.body_entered.connect(_load_nex_level)


# Load the next level (the next scene)
func _load_nex_level(body):
	if body.is_in_group("player"):
		var scene = "res://scenes/game/levels/rooms/scene_2/scene_2.tscn"
		#SceneTransition.change_scene(scene) # For now, we will not use this scene change
