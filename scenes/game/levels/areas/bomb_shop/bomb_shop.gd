extends Node2D
## Script that controls the exchange of coins for bombs
##
## Displays dialogs with an NPC, handles events in the dialog, and adds bombs while reducing coins

# Value of each bomb and the currency
@export var bomb_value = 5
@export var bomb_money = "GoldCoin"
# Purchase dialog
@export var buy_dialogue: DialogueResource
# Failed purchase dialog
@export var failed_dialogue: DialogueResource
# Successful purchase dialog
@export var success_dialogue: DialogueResource

var _ended = false # Guardamos si ya terminamos la compra
var _responses = [] # Guardamos las respuestas seleccionadas

# Reference to the NPC
@onready var npc = $NPC/BigGuy


# Initialization function
func _ready():
	# Disable NPC collisions and listen for dialog events
	npc.disabled_collision(true)
	npc.on_dialogue_ended(_on_dialogue_ended)
	npc.on_response_selected(_on_response_selected)


# Proceed to buy a quantity of bombs
# If the quantity can be bought, return "true", otherwise "false"
# If the "amount" is "-1", it will try to buy as many bombs as possible
# (if at least 1 is bought, return "true")
func _buy_bombs(amount: int):
	# Amount of available coins
	var coins = HealthDashboard.points[bomb_money]
	
	if amount < 0:
		# Calculate the number of bombs we can buy
		amount = int(coins / bomb_value)

	if amount == 0:
		return false # Si la cantidad es 0, retornamos "false" (no se pudo comprar)

	# Buy a specific quantity of bombs
	var total = amount * bomb_value
	if  total <= coins:
		# If the total to spend is less than the total coins, proceed to buy
		HealthDashboard.add_points(bomb_money, -total) # Reduce coins
		HealthDashboard.add_bomb(amount) # Increase bombs
		return true
	else:
		return false


# When the dialog ends, proceed to buy bombs or show the completion dialog
func _on_dialogue_ended():
	if _ended:
		# Reset the dialog and variables to "buy again"
		_ended = false
		_responses = []
		npc.set_dialogue(buy_dialogue)
	else:
		# Try to make the purchase and end the conversation
		_ended = true
		var amount = _get_selected_amount()
		var bought = _buy_bombs(amount)
		if bought:
			# If the purchase was successful, show the "success" dialog
			npc.set_and_show_dialogue(success_dialogue)
		else:
			# If the purchase failed, show the "failed" dialog
			npc.set_and_show_dialogue(failed_dialogue)


# Save the selected responses
func _on_response_selected(response: String):
	_responses.append(response)


# Get the selected quantity to buy, depending on the selected response
func _get_selected_amount():
	var amount = 0
	for r in _responses:
		if (r as String).contains("una"):
			amount = 1
		elif (r as String).contains("tres"):
			amount = 3
		elif (r as String).contains("cinco"):
			amount = 5
		elif (r as String).contains("monedas"):
			amount = -1
	return amount
