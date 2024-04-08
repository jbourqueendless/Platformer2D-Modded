extends CanvasLayer
## Object script for scene change.
##
## It is a node that represents an object and changes to the next scene upon contact
## Scene change: https://docs.google.com/document/d/1eIBtgr8wln1pT0aZ4c-YWk_pqngyBg4HDsgdYLAXv28/edit?usp=sharing
## Use of signals: https://docs.google.com/document/d/1vFSOuJkBy7xr5jksgCBNaTpqJHE_K87ZNafB5ZJ_I0M/edit?usp=sharing
## Use of objects for scene change: https://docs.google.com/document/d/1DeAuU4dYa7DsWs-ht5Aiq4mFraOOu7hraNgIeSZn4lA/edit?usp=sharing


# Public variables for life and score
var life = 10 # Variable para menejo de vida
# Variable for managing points and the number of bombs
var points = {
	"GoldCoin": 0,
	"SilverCoin": 0,
	"BlueDiamond": 0,
	"GreenDiamond": 0,
	"RedDiamond": 0,
	"Bomb": 0,
}

# Auxiliary variables to change the score of a type of collectible object
var _number_1: TextureRect
var _number_2: TextureRect
var _number_3: TextureRect

# Index where number 1 starts in the atlas image of letters and numbers
var _index_number_1 = 8
# Exact index of number 0, in the atlas image of letters and numbers
var _index_number_0 = 17

# References to the life bar and the score numbers
@onready var bar = $LifeBar/Bar
@onready var point_group = $PointGroup
@onready var bomb_group = $LifeBar/Bomb


# Initialization function
func _ready():
	self.visible = false


# Adds life to the main character, according to the provided value
func add_life(value: int):
	life += value
	if life > 10:
		life = 10
	_set_life_progress(life)


# Removes life from the main character, according to the provided value
func remove_life(value: int):
	life -= value
	if life < 0:
		life = 0
	_set_life_progress(life)


# Adds points to the main character (adds up the total points)	
func add_points(type: String, value: int, group = null):
	if not group:
		group = point_group.find_child(type)
	if group:
		_number_1 = group.find_child("Number1")
		_number_2 = group.find_child("Number2")
		_number_3 = group.find_child("Number3")
		# We save the corresponding score
		points[type] += value
		_set_points(points[type])


# Allows adding or subtracting the number of available bombs
func add_bomb(value: int):
	add_points("Bomb", value, bomb_group)


# Function to reset the values of life and points
func restart():
	life = 10
	_set_life_progress(life)
	# Reset all different types of points
	for type in points:
		var group = point_group.find_child(type)
		if not group:
			group = bomb_group
			
		_number_1 = group.find_child("Number1")
		_number_2 = group.find_child("Number2")
		_number_3 = group.find_child("Number3")
		points[type] = 0
		_set_points(points[type])


# Updates the progress bar of life to the provided value
func _set_life_progress(value: int):
	bar.value = value


# Updates the number of points obtained by the user (using images as numbers)
func _set_points(value: int):
	# The maximum value to represent is 999
	if value > 999:
		value = 999
	var digit_str = str(value)  # Converts the number to a string
	var digit_list = digit_str.split("") # Splits the string into a list of characters
	
	# We fill the list with 0 at the beginning if the number is less than 99
	if value < 100:
		for i in range(3 - digit_list.size()):
			digit_list.insert(0, "0") # We insert zeros at the beginning
	
	for index in range(digit_list.size()):
		var n = digit_list[index]
		var region = Rect2()
		if n == "0":
			region = _get_text_region(_index_number_0)
		else:
			var v = int(n)
			# We generate a position using the number plus the position of the digits in the "atlas"
			# and subtract 1, because _index_number_1 already has the position of number 1
			var position = v + _index_number_1 - 1
			region = _get_text_region(position)
		match index:  # We update each image (3 images from 0 to 2)
			0:
				_number_1.texture.set_region(region)
			1:
				_number_2.texture.set_region(region)
			2:
				_number_3.texture.set_region(region)


# Generates a region (Rect2) for the character position according to the "Image Atlas"
# It takes the position of the letter from 0 to N, and returns a Rect2, to draw the specific letter or number
func _get_text_region(position: int):
	var w = 10 # Ancho de la letra (siempre es 10)
	var h = 11 # Alto de la letra (siempre es 11)
	var x = 4.0 # Valor de la posición X (inicia con el valor 4)
	var y = 4.0 # Valor de la posición Y (inicia con el valor 4)
	var delta = 20.0 # Separación entre letras
	var column_count = 6.0 # Número de columnas según el atlas generado (en este caso 6)
	
	# We generate a loop, to move through each region (each letter)
	for p in range(position):
		if x / delta < column_count - 1.0:
			# We move through the columns
			x += delta # We move to the next column
		else:
			# If we reach the last column, we continue from the next row
			x = 4 # We go back to the first column
			y += delta # We move to the next row
			
	return Rect2(x, y, w, h)
