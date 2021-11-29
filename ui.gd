extends Control

var selected_planet
var is_selecting
var planet_labels = []
onready var modeline = $modeline

func _ready():
	modeline.text = '[G] go to planet'
	remove_selection()

func _unhandled_input(event):
	if event.is_action_released('g'):
		start_selecting()
	elif event.is_action_released('esc'):
		stop_selecting()
		remove_selection()
	elif event.is_action_pressed('r') and is_instance_valid(selected_planet):
		selected_planet.set_building(selected_planet.building_type.RESOURCE)
		modeline.text = '[G] go to planet%s' % line_for_planet(selected_planet)
	elif event.is_action_pressed('s') and is_instance_valid(selected_planet):
		selected_planet.set_building(selected_planet.building_type.SHIPYARD)
		modeline.text = '[G] go to planet%s' % line_for_planet(selected_planet)
	elif event.is_action_pressed('d') and is_instance_valid(selected_planet):
		selected_planet.set_building(Planet.building_type.DEFENSE)
		modeline.text = '[G] go to planet%s' % line_for_planet(selected_planet)
	elif event is InputEventKey and not event.pressed and is_selecting:
		var planets = get_tree().get_nodes_in_group('planets')
		var planet
		for other_planet in planets:
			if other_planet.character == event.scancode:
				planet = other_planet
		if is_instance_valid(planet):
			stop_selecting()
			modeline.text = '[G] go to planet%s' % line_for_planet(planet)
			planet.selected = true
			selected_planet = planet

func line_for_planet(planet):
	if planet.building == planet.building_type.NONE:
		return '   [R] build resource extractor   [S] build cargo shipyard   [D] build defense shipyard'
	else:
		return ''

func start_selecting():
	modeline.text = ''
	remove_selection()
	is_selecting = true
	var planets = get_tree().get_nodes_in_group('planets')
	for planet in planets:
		var position = get_viewport().canvas_transform.xform(planet.global_position + Vector2(0, planet.radius * 1.2)) + Vector2(-10, 20)
			
		var label = Label.new()
		label.text = '[%s]' % OS.get_scancode_string(planet.character)
		label.margin_left = position.x
		label.margin_top = position.y
		add_child(label)
		planet_labels.push_back(label)

func stop_selecting():
	is_selecting = false
	for label in planet_labels:
		remove_child(label)
		label.queue_free()
	planet_labels = []

func remove_selection():
	modeline.text = '[G] go to planet'
	if is_instance_valid(selected_planet):
		selected_planet.selected = false
	selected_planet = null
