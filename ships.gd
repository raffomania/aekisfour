extends MultiMeshInstance2D

var ships: Array = []

func _ready():
	for i in range(self.multimesh.instance_count):
		var ship = Ship.new()
		ship.init(Vector2(1920/2, 1080/2))
		ships.push_back(ship)
		multimesh.set_instance_transform_2d(i, ships[i].transform)

func _process(dt):
	var planets = get_tree().get_nodes_in_group('planets')
	for i in range(self.multimesh.instance_count):
		var ship = ships[i]
		if not is_instance_valid(ship.target):
			ship.update_target(planets)
		ship.update(dt)
		multimesh.set_instance_transform_2d(i, ship.transform)

func add_ship(position):
	multimesh.instance_count += 1
	var ship = Ship.new()
	ship.init(position)
	ships.push_back(ship)

class Ship:
	var transform: Transform2D
	var target: Planet
	var resources = 0

	func init(position):
		transform = Transform2D().translated(position)

	func update(dt):
		if is_instance_valid(target):
			var direction = target.global_position - transform.origin
			if direction.length_squared() < 50:
				process_target()
			else:
				transform = Transform2D().rotated(direction.angle())\
					.translated((transform.origin + dt * 100 * direction.normalized()).rotated(-direction.angle()))
		
	func process_target():
		if target.building == target.building_type.RESOURCE and target.resources > 0 and resources == 0:
			target.resources -= 1
			resources += 1
		elif target.building == target.building_type.SHIPYARD and resources > 0:
			resources -= 1
			target.resources += 1
		target = null

	func update_target(planets):
		for planet in planets:
			if planet.building == planet.building_type.SHIPYARD and resources > 0:
				target = planet
				return
			elif planet.building == planet.building_type.RESOURCE and resources == 0:
				target = planet
				return
