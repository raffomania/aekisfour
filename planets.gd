extends Node

var planet_res = preload('res://planet.tscn')
var characters = [KEY_H, KEY_J, KEY_K, KEY_L]
var planets = []

func _ready():
	yield(get_tree().root, 'ready')
	randomize()
	for character in characters:
		var planet = planet_res.instance()
		planet.character = character
		planet.global_position = Vector2(randf() * 2700, randf() * 1500)
		add_child(planet)
		planets.push_back(planet)
