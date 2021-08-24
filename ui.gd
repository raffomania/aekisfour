extends Control

var planets
var characters = [KEY_H, KEY_J, KEY_K, KEY_L]
var by_char = {}
var selected_planet
var is_selecting
onready var modeline = $modeline

func _ready():
	yield(get_tree().root, "ready")
	planets = get_tree().get_nodes_in_group('planets')
	for i in range(planets.size()):
		by_char[characters[i]] = planets[i]
		planets[i].character = characters[i]
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
	elif event is InputEventKey and not event.pressed and is_selecting:
		var planet = by_char.get(event.scancode)
		if is_instance_valid(planet):
			stop_selecting()
			modeline.text = '[G] go to planet%s' % line_for_planet(planet)
			planet.selected = true
			selected_planet = planet

func line_for_planet(planet):
	if planet.building == planet.building_type.NONE:
		return '   [R] build resource extractor   [S] build shipyard'
	else:
		return ''

func start_selecting():
	modeline.text = ''
	remove_selection()
	is_selecting = true
	for planet in planets:
		planet.show_label = true

func stop_selecting():
	is_selecting = false
	for planet in planets:
		planet.show_label = false

func remove_selection():
	modeline.text = '[G] go to planet'
	if is_instance_valid(selected_planet):
		selected_planet.selected = false
	selected_planet = null
