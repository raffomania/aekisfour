extends MultiMeshInstance2D

class_name DefenseShips

var ships: Array = []

func _ready():
	yield($'../planets', 'planets_updated')
	var planet = get_tree().get_nodes_in_group('planets')[0]
	for i in range(self.multimesh.visible_instance_count):
		var ship = DefenseShip.new()
		ship.init(planet.global_position)
		ships.push_back(ship)
		multimesh.set_instance_transform_2d(i, ships[i].transform)
		multimesh.set_instance_color(i, Color.white)

func _process(dt):
	var enemies = $'../enemy_ships'.ships
	for i in range(self.multimesh.visible_instance_count):
		var ship = ships[i]
		if not is_instance_valid(ship.target):
			ship.update_target(enemies)
		ship.update(dt)
		multimesh.set_instance_transform_2d(i, ship.transform)
	update()

func _draw():
	for ship in ships:
		if ship.laser != null:
			draw_line(ship.transform.origin, ship.laser, Color.white, 3.0)

func add_ship(position):
	var ship = DefenseShip.new()
	ship.init(position)
	ships.push_back(ship)
	multimesh.set_instance_transform_2d(multimesh.visible_instance_count, ship.transform)
	multimesh.set_instance_color(multimesh.visible_instance_count, Color.white)
	multimesh.visible_instance_count += 1

class DefenseShip:
	var transform: Transform2D
	var last_target: Vector2
	var target = null
	var random_direction: Vector2 = Vector2(1, 0).rotated(randf() * TAU)
	var velocity: Vector2 = Vector2(randf() - 0.5, randf() - 0.5)
	var time_since_shot = 0
	var laser = null
	const capacity = 2
	const max_speed = 80
	const steering = 1.5
	const acceleration = 20
	const random_wander_strength = 2
	const cooldown = 2

	func init(position: Vector2):
		transform = Transform2D().translated(position)
		last_target = position

	func update(dt):
		var direction: Vector2 = velocity.normalized()
		var actual_acceleration = acceleration
		time_since_shot += dt

		# if the target was killed by another ship, look for a new one
		if target != null and target.health <= 0:
			target = null

		if target != null:
			var to_target = target.transform.origin - transform.origin
			direction = to_target.normalized()

			if to_target.length_squared() < 6000:
				actual_acceleration = -0.1 * dt

			# shoot the target
			if to_target.length_squared() < 2000 and time_since_shot > cooldown:
				process_target()
		else:
			random_direction = random_direction.rotated((randf() - 0.5) * TAU * dt * random_wander_strength)

			var back_home = last_target - transform.origin
			var too_far_distance = back_home.length() - get_max_distance_from_home()
			var distance_from_home_factor = max(0, too_far_distance * 0.001)
			random_direction = random_direction.slerp(back_home.normalized(), clamp(distance_from_home_factor, 0, 1))

			direction = random_direction
		
		# remove laser beam after a little while
		if laser != null and time_since_shot > 0.2:
			laser = null

		
		velocity = velocity.normalized().slerp(direction, steering * dt) \
			* velocity.length() \
			+ (velocity.normalized() * actual_acceleration * dt)
		
		velocity = velocity.clamped(max_speed)

		var new_transform = Transform2D().rotated(velocity.angle())
		new_transform.origin = transform.origin + dt * velocity
		transform = new_transform

	func process_target():
		target.health -= 1
		time_since_shot = 0
		laser = target.transform.origin
		if target.health <= 0:
			target = null

	func update_target(enemies):
		var nearest = null
		var distance_to_nearest = null
		for enemy in enemies:
			var distance = enemy.transform.origin.distance_to(transform.origin)
			if (distance < 500 and 
					(nearest == null or distance < distance_to_nearest)):
				nearest = enemy
				distance_to_nearest = nearest.transform.origin.distance_to(transform.origin)
		target = nearest
	
	static func get_max_distance_from_home():
		return 200
