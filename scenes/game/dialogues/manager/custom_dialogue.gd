extends Node
## Script for custom dialogs
##
## Create and display dialogs using a custom visualization


# Definition of the custom dialog template
var _path_custom_dialogue = "res://scenes/game/dialogues/balloon/balloon.tscn"
var _custom_dialogue: PackedScene


# Initialization function
func _ready():
	_custom_dialogue = load(_path_custom_dialogue)


# Create a new dialog and return it
func create():
	var _dialog = _custom_dialogue.instantiate()
	return _dialog


# Show the dialog
func show_dialogue(_dialog: Node, _resource: DialogueResource, _start = "start"):
	# Agregamos el diálogo a la escena actual
	get_tree().current_scene.add_child(_dialog)
	# Inicimos (mostramos) el diálogo
	_dialog.start(_resource, _start)


# Create and show the dialog (return the dialog)
func create_and_show_dialogue(_resource: DialogueResource, _start = "start"):
	var _dialog = create()
	show_dialogue(_dialog, _resource, _start)
	return _dialog
