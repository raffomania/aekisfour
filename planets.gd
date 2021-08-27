extends Node

var planet_res = preload('res://planet.tscn')
var characters = [KEY_H, KEY_J, KEY_K, KEY_L]
var planets = []

func _ready():
	yield(get_tree().root, 'ready')
	randomize()
	for i in range(4):
		var planet = planet_res.instance()
		planet.character = characters[i]
		planet.global_position = Vector2(randf() * 1800, randf() * 800)
		add_child(planet)
		planets.push_back(planet)
