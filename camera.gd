extends Node2D

func _ready():
	var _e = $'../planets'.connect('planets_updated', self, 'update')

func update():
	var planets = get_tree().get_nodes_in_group('planets')
	if len(planets) == 0:
		return

	var extents = Rect2()
	extents.position = planets[0].position
	for planet in planets:
		extents = extents.expand(planet.position)
	
	extents.position -= extents.size * 0.2
	extents.size += extents.size * 0.4

	var screen_size = Vector2(1920, 1080)
	var scale = min(screen_size.x / extents.size.x, screen_size.y / extents.size.y)

	var offset = extents.position
	var margin = (screen_size - extents.size * scale) / 2
	offset -= margin / scale

	var transform = Transform2D()
	transform.origin = -offset
	transform = transform.scaled(Vector2(scale, scale))

	get_viewport().canvas_transform = transform
