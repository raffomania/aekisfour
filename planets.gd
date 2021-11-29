extends Node

var planet_res = preload('res://planet.tscn')
var characters = [KEY_H, KEY_J, KEY_K, KEY_L, KEY_Y, KEY_U, KEY_I, KEY_O]
var all_planets = []
var discovered_planets = []
signal planets_updated

func _ready():
	yield(get_tree().root, 'ready')
	randomize()
	var last_planet_pos = Vector2(0, 0)
	for character in characters:
		var planet = planet_res.instance()
		planet.character = character
		
		planet.global_position = get_new_planet_position(last_planet_pos)
		add_child(planet)

		last_planet_pos = planet.global_position

		all_planets.push_back(planet)
		planet.add_to_group('planets')
		discovered_planets.push_back(planet)

		emit_signal('planets_updated')

		# use for debugging planet generation 
		# yield(get_tree().create_timer(1.5), 'timeout')

func get_new_planet_position(last_position: Vector2):
	var position = Vector2(1, 0).rotated(randf() * TAU)\
		* CargoShips.CargoShip.get_max_distance_from_home()\
		+ last_position

	var near_planets = []
	for planet in all_planets:
		var from_other = position - planet.global_position
		if from_other.length() < 150:
			near_planets.push_back(from_other.normalized())

	if len(near_planets) > 0:
		var away_from_others = Vector2(0, 0)
		for force in near_planets:
			away_from_others += force / len(near_planets)
		position += away_from_others * 100

	return position
