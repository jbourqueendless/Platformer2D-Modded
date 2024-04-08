extends CanvasLayer
## Class that controls Dialogues
##
## Text preparations for dialogues are made, the order in which texts appear is controlled
## The logic of receiving player responses, dialogue size calculations when the game window size changes 


# DOCUMENTATION TOOLTIPS FOR NPC DIALOGUES: https://docs.google.com/document/d/15bKBdC0nMawhdyuVRRfcZbFD7D59Lb8HhKiGBY70FL0
# DOCUMENTATION WHAT ARE SIGNALS IN GDSCRIPT?: https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo

# Dialogue completion signal
signal dialogue_ended()
# Signal that is emitted when a response is chosen
signal response_selected(response: String)

const PATH_SPRITES = "res://scenes/game/dialogues/persons/"

# Exporting response template
@export var response_template: Node

# Dialogue resource
var _resource: DialogueResource
# Temporary game states
var _temporary_game_states: Array = []
# Variable that validates if we are waiting for the player's response
var _is_waiting_for_input: bool = false
# Dialogue thread
var dialogue_line: DialogueLine:
	# We create the dialogue line
	set(next_dialogue_line):
		# If there are no texts
		if not next_dialogue_line:
			# We finish and return
			return _end_dialogue()
		
		# We are not waiting for the player's response
		_is_waiting_for_input = false
		
		# We remove previous responses
		for child in responses_menu.get_children():
			responses_menu.remove_child(child)
			child.queue_free()
		
		# We assign the first dialogue
		dialogue_line = next_dialogue_line
		# We display the dialogue
		character_label.visible = not dialogue_line.character.is_empty()
		# We display the title
		character_label.text = tr(dialogue_line.character, "dialogue")
		# We remove the inserted nodes
		for n in portrait_node.get_children():
			portrait_node.remove_child(n)
			n.queue_free()
		# We display the avatar
		portrait_node.add_child(_get_texture_for_dialogue(dialogue_line.character))
		
		# We adjust the dialogue properties
		dialogue_label.modulate.a = 0
		dialogue_label.custom_minimum_size.x = dialogue_label.get_parent().size.x - 1
		dialogue_label.dialogue_line = dialogue_line
		
		# We display responses if they exist
		responses_menu.modulate.a = 0
		if dialogue_line.responses.size() > 0:
			for response in dialogue_line.responses:
				# We duplicate the template to use the styles
				var item: RichTextLabel = response_template.duplicate(0)
				item.name = "Response%d" % responses_menu.get_child_count()
				if not response.is_allowed:
					item.name = String(item.name) + "Disallowed"
					item.modulate.a = 0.4
				item.text = response.text
				item.show()
				responses_menu.add_child(item)
		
		# We display the dialogue
		balloon.show()
		
		dialogue_label.modulate.a = 1
		dialogue_label.type_out()
		await dialogue_label.finished_typing
		
		# We wait for the player's response
		if dialogue_line.responses.size() > 0:
			responses_menu.modulate.a = 1
			_configure_menu()
		elif dialogue_line.time != null:
			# We move to the next dialogue
			var time = (
				dialogue_line.dialogue.length() * 0.02 if dialogue_line.time == "auto" 
				else dialogue_line.time.to_float()
			)
			await get_tree().create_timer(time).timeout
			_next(dialogue_line.next_id)
		else:
			_is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
	get:
		return dialogue_line # Retornamos la linea del diálogo

# Dialogue definition
@onready var balloon: ColorRect = $Balloon
# Margin node definition
@onready var margin: MarginContainer = $Balloon/Margin
@onready var portrait_node: Control = $Balloon/Margin/HBox/Portrate
# Avatar node definition
@onready var character_portrait: Sprite2D = $Balloon/Margin/HBox/Portrate/Sprite2D
# Character name node definition
@onready var character_label: RichTextLabel = $Balloon/Margin/HBox/VBox/CharacterLabel
# Dialogue node definition
@onready var dialogue_label := $Balloon/Margin/HBox/VBox/DialogueLabel
# Responses node definition
@onready var responses_menu: VBoxContainer = $Balloon/Margin/HBox/VBox/Responses
# You can read more about nodes in this document: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Function called when the scene is loaded
func _ready() -> void:
	# We hide the dialogue
	response_template.hide()
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)


func _unhandled_input(_event: InputEvent) -> void:
	# We set the dialogue to receive player responses
	get_viewport().set_input_as_handled()


# We start the dialogue
func start(dialogue_resource: DialogueResource, 
		title: String, extra_game_states: Array = []) -> void:
	_temporary_game_states = extra_game_states
	_is_waiting_for_input = false
	_resource = dialogue_resource
	# We set the dialogue texts
	self.dialogue_line = await _resource.get_next_dialogue_line(title, _temporary_game_states)


# Go to the next line
func _next(next_id: String) -> void:
	self.dialogue_line = await _resource.get_next_dialogue_line(next_id, _temporary_game_states)


# We listen to buttons and response signals
func _configure_menu() -> void:
	balloon.focus_mode = Control.FOCUS_NONE
	
	var items = _get_responses()
	for i in items.size():
		var item: Control = items[i]
		
		item.focus_mode = Control.FOCUS_ALL
		
		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()
		
		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
		
		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.gui_input.connect(_on_response_gui_input.bind(item))
	
	items[0].grab_focus()


# We get the list of available responses
func _get_responses() -> Array:
	var items: Array = []
	for child in responses_menu.get_children():
		if "Disallowed" in child.name: continue
		items.append(child)
		
	return items


# We adjust the size of the dialogue
func _handle_resize() -> void:
	if not is_instance_valid(margin):
		call_deferred("_handle_resize")
		return
	
	balloon.custom_minimum_size.y = margin.size.y
	balloon.size.y = 0
	var viewport_size = balloon.get_viewport_rect().size
	balloon.global_position = Vector2(
		(viewport_size.x - balloon.size.x) * 0.5, 
		viewport_size.y - balloon.size.y)


#  We hide the dialogue
func _on_mutated(_mutation: Dictionary) -> void:
	_is_waiting_for_input = false
	balloon.hide()


# We listen when the mouse enters the response area
func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: 
		return
	item.grab_focus()


# We set the chosen responses
func _on_response_gui_input(event: InputEvent, item: Control) -> void:
	if "Disallowed" in item.name: 
		return
	# We move to the next line of dialogue
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		response_selected.emit(dialogue_line.responses[item.get_index()].text)
		_next(dialogue_line.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in _get_responses():
		response_selected.emit(dialogue_line.responses[item.get_index()].text)
		_next(dialogue_line.responses[item.get_index()].next_id)


# We set the next dialogue lines
func _on_balloon_gui_input(event: InputEvent) -> void:
	if not _is_waiting_for_input: 
		return
	# We exit if there is no more text
	if dialogue_line.responses.size() > 0: return

	# When there are no responses, we give the option to click on the dialogue
	get_viewport().set_input_as_handled()
	
	# With the click, we change the dialogue lines
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		_next(dialogue_line.next_id)
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == balloon:
		_next(dialogue_line.next_id)


# If the resolution changes, we recalculate the size of the dialogue
func _on_margin_resized() -> void:
	_handle_resize()


# We load the image of the character who is dialoguing
func _get_texture_for_dialogue(character: String):
	# We get the first name
	var person = character.to_lower().split(" ")[0]
	# We define the scene to insert
	var filename = "%s/" % [person] + "%s.tscn" % [person]
	# We return the avatar
	return load(PATH_SPRITES + filename).instantiate()


# It is executed when the dialogue ends
func _end_dialogue():
	# We finish the dialogue
	queue_free()
	# We emit the dialogue completion signal
	self.emit_signal("dialogue_ended")


# We connect the end of the dialogue (to listen when the dialogue ends)
func on_dialogue_ended(fn):
	dialogue_ended.connect(fn)


# We connect the signal to get selected responses in the dialogue
func on_response_selected(fn):
	response_selected.connect(fn)
