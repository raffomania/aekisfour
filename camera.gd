extends Node2D

func _ready():
	yield(get_tree().root, "ready")
	var planets = get_tree().get_nodes_in_group('planets')
	var extents = Rect2()
	extents.position = planets[0].position
	for planet in planets:
		extents = extents.expand(planet.position)
	var screen_size = Vector2(1920, 1080)
	var offset = extents.position
	offset -= screen_size / 2
	offset += extents.size / 2
	get_viewport().canvas_transform = Transform2D().translated(-offset)

