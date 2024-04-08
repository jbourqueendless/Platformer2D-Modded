extends Node2D
## Inventory Class
##
## Rendering of inventory cells and objects, functionalities for adding new objects and removing objects from inventory
## Checking objects placed on the main character


# Reference to all "boxes" containing objects
var _item_contents = []
# Reference to all object names in the inventory
var _item_object_names = []
# Reference to the items
var _item_objects = []


@onready var canvas = $CanvasLayer # Main canvas
@onready var animation_player = $CanvasLayer/AnimationPlayer # Player
@onready var grid = $CanvasLayer/Inventory/GridContainer # Grid al cual se añaden elementos


# Initialization function
func _ready():
	# Each collected "item" will be added inside a "container"
	# This container is a "sprite" that has an image with a "border" simulating a frame
	# Inside this "frame" is where the "items" will be added
	# To avoid adding all the nodes manually (6 nodes in this case), a loop was made
	# that will add them dynamically.
	for n in 6:
		var item = load("res://scenes/game/inventory/item_content/item_content.tscn").instantiate()
		grid.add_child(item) # Agregamos el nodo "marco" a un grid
		_item_contents.append(item) # Save the reference of the "frame" node in an array

# Function to detect keyboard or mouse events
func _unhandled_input(event):
	# Define scenes where the inventory should not appear
	var scenes = ["Splash", "Init"]
	# Get the name of the current scene
	var actual_scene = get_tree().get_current_scene().name
	# If we are in the defined scenes, do not show the inventory
	if scenes.find(actual_scene,0) > -1:
		return
	
	if event.is_action_pressed("wheel_up"):
		# When we scroll the mouse wheel up, hide the inventory
		animation_player.play_backwards("down")
		await animation_player.animation_finished
		canvas.visible = false
		get_tree().paused = false
	elif event.is_action_pressed("wheel_down"):
		get_tree().paused = true
		# When we scroll the mouse wheel down, show the inventory
		if canvas.visible == true:
			return
		canvas.visible = true
		animation_player.play("down")
		await animation_player.animation_finished


# Function to add an item to the inventory
# Adding means, loading an element (scene) and adding it to the grid
# The name of the item must exist as a scene
# Example of name: blue_potion or green_bottle
func add_item_by_name(_name: String):
	# If the item already exists (already added), end the function
	var index = _item_object_names.find(_name)
	if index >= 0:
		# Get the available number of the object
		var _num_available = _item_objects[index].get_num()
		# Add one
		_num_available += 1
		# Update new number
		var _num = _item_objects[index].set_num(str(_num_available))
		return
	
	# Load the resource
	var item_to_load = load("res://scenes/game/levels/objects/power_up/power_up_item.tscn")
	
	# If the resource does not exist, end the function
	if not item_to_load:
		return
	
	# Add the item to the grid, and save the references (to be able to remove it if required)
	index = _item_object_names.size()
	var item = item_to_load.instantiate()
	var item_content = _item_contents[index]
	item_content.add_child(item)
	item.set_animation(_name)
	_item_object_names.append(_name);
	_item_objects.append(item)


# Remove an item from the inventory
# Removing means, finding the "node" and removing it from the main grid
# When removing the node, all other nodes afterwards will move "backwards"
# to avoid leaving "empty spaces"
# Example of name: blue_potion or green_bottle
func remove_item_by_name(_name: String):
	var index = _item_object_names.find(_name)
	if index >= 0:
		var item_content = _item_contents[index] # Nodo que es un "cuadro" contenedor del item recolectado
		var item = _item_objects[index] # Nodo que tiene el item recolectado
		# Adjust the available quantity
		var _num_available = _item_objects[index].get_num()
		_num_available -= 1 
		if _num_available > 0:
			var _num = _item_objects[index].set_num(str(_num_available))
			return
		else:
			# Remove the item node
			item_content.remove_child(item)
			item.queue_free(); # Liberamos memoria (porque no lo vamos a volver a usar)
			
			# Move all items "backwards" so they occupy the empty space
			var size = _item_objects.size()
			for n in range(index, size - 1):
				var current_content = _item_contents[n]
				var next_content = _item_contents[n + 1]
				var next_item = _item_objects[n + 1];
				# Remove the "next_item" item (but do not free memory)
				next_content.remove_child(next_item);
				# The previously removed item is reused (added) in another node
				current_content.add_child(next_item);
			
			# Remove the name from the list of "item names"
			_item_object_names.remove_at(index)
			
			# Remove the node from the item type node list
			_item_objects.remove_at(index)


# Remove all items from the inventory
func remove_all_items():
	var size = _item_object_names.size()
	for i in size:
		remove_item_by_name(_item_object_names[size - i - 1])


# Return a list of item names in the inventory
func get_item_list_names():
	return _item_object_names


func show_inventory(show: bool):
	canvas.visible = show
	get_tree().paused = show
