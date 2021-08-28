extends MultiMeshInstance2D

var ships: Array = []

func _ready():
	yield($'../planets', 'planets_updated')
	var planet = get_tree().get_nodes_in_group('planets')[0]
	for i in range(self.multimesh.instance_count):
		var ship = Ship.new()
		ship.init(planet.global_position)
		ships.push_back(ship)
		multimesh.set_instance_transform_2d(i, ships[i].transform)

func _process(dt):
	var planets = get_tree().get_nodes_in_group('planets')
	for i in range(self.multimesh.instance_count):
		var ship = ships[i]
		if not is_instance_valid(ship.target):
			ship.update_target(planets)
		ship.update(dt, ships)
		multimesh.set_instance_transform_2d(i, ship.transform)
	update()

func _draw():
	for ship in ships:
		for i in range(ship.resources):
			draw_circle(ship.transform.translated(Vector2(-10 + i * -5, 0)).origin, 2, Color.white)

func add_ship(position):
	multimesh.instance_count += 1
	var ship = Ship.new()
	ship.init(position)
	ships.push_back(ship)

class Ship:
	var transform: Transform2D
	var last_target: Vector2
	var target: Planet
	var random_direction: Vector2 = Vector2(1, 0).rotated(randf() * TAU)
	var velocity: Vector2 = Vector2(randf() - 0.5, randf() - 0.5)
	var resources = 0
	var reserved_resources = 0
	const capacity = 2
	const max_speed = 100
	const steering = 1.45
	const acceleration = 0.145
	const separation = 0.03
	const max_distance_from_home = 300
	const random_wander_strength = 2

	func init(position: Vector2):
		transform = Transform2D().translated(position)
		last_target = position

	func update(dt, ships):
		var direction: Vector2 = velocity.normalized()
		var deceleration = 0
		if is_instance_valid(target):
			var to_target = target.global_position - transform.origin
			if to_target.length_squared() < 2000:
				process_target()
			else:
				direction = to_target.normalized()
				deceleration = clamp((400 - to_target.length())/400, 0, 1) * acceleration
		else:
			random_direction = random_direction.rotated((randf() - 0.5) * TAU * dt * random_wander_strength)

			var back_home = last_target - transform.origin
			var too_far_distance = back_home.length() - max_distance_from_home
			var distance_from_home_factor = max(0, too_far_distance * 0.001)
			random_direction = random_direction.slerp(back_home.normalized(), clamp(distance_from_home_factor, 0, 1))

			direction = random_direction
		
		for ship in ships:
			if ship == self:
				continue

			var from_other_to_self = self.transform.origin - ship.transform.origin
			if from_other_to_self.length_squared() < 1500:
				direction = direction.slerp(from_other_to_self.normalized(), separation)

		velocity = velocity.normalized().slerp(direction, steering * dt) \
			* lerp(velocity.length(), max_speed, (acceleration - deceleration) * dt) \
			* (1 - deceleration * dt)

		var new_transform = Transform2D().rotated(velocity.angle())
		new_transform.origin = transform.origin + dt * velocity
		transform = new_transform

	func process_target():
		if target.building == target.building_type.RESOURCE and target.resources > 0 and resources < capacity:
			var amount = min(capacity - resources, target.resources)
			target.resources -= amount
			resources += amount
		elif target.building == target.building_type.SHIPYARD and resources > 0:
			target.resources += resources
			resources = 0
		target.reserved_resources -= reserved_resources
		reserved_resources = 0
		last_target = target.global_position
		target = null

	func update_target(planets):
		for planet in planets:
			if planet.building == planet.building_type.SHIPYARD and resources > 0:
				target = planet
				return
			elif planet.building == planet.building_type.RESOURCE and resources == 0 and planet.reserved_resources < planet.resources:
				target = planet
				planet.reserved_resources += capacity - resources
				reserved_resources = capacity - resources
				return
