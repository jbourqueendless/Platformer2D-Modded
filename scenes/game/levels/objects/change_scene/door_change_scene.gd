extends Node2D
## Scene change object script.
##
## It is a node that represents an object and when it comes into contact it changes to a next scene
## Scene changes: https://docs.google.com/document/d/1eIBtgr8wln1pT0aZ4c-YWk_pqngyBg4HDsgdYLAXv28/edit?usp=sharing
## Use of signals: https://docs.google.com/document/d/1vFSOuJkBy7xr5jksgCBNaTpqJHE_K87ZNafB5ZJ_I0M/edit?usp=sharing
## Use of objects for scene change: https://docs.google.com/document/d/1DeAuU4dYa7DsWs-ht5Aiq4mFraOOu7hraNgIeSZn4lA/edit?usp=sharing


# Path to the scene to load
@export var _path_to_scene = ""

# Reference to the area
@onready var _area = $Area2D


# Initialization function
func _ready():
	_area.body_entered.connect(_load_nex_level)


# Load the next level (the next scene)
func _load_nex_level(body):
	# Change scene if the path is not empty and the main character comes into contact
	if _path_to_scene != "" and body.is_in_group("player"):
		SceneTransition.change_scene(_path_to_scene)
