extends Node2D

func _ready():
	yield(get_tree().create_timer(0.1), 'timeout')
	update()

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
	print(scale)

	var offset = extents.position
	var margin = (screen_size - extents.size * scale) / 2
	print(extents.size.y, ' ', extents.size.y * scale)
	print(margin.y)
	offset -= margin / scale

	var transform = Transform2D()
	transform.origin = -offset
	transform = transform.scaled(Vector2(scale, scale))

	get_viewport().canvas_transform = transform
