
extends MultiMeshInstance2D

class_name EnemyShips

var ships: Array = []
var lasers: Array = []
var enemies_to_spawn = 1

func _ready():
	yield($'../planets', 'planets_updated')
	var timer = Timer.new()
	timer.wait_time = 30
	timer.connect('timeout', self, 'spawn_wave')
	add_child(timer)
	timer.start()

func _process(dt):
	var planets = get_tree().get_nodes_in_group('planets')

	# remove dead ships first, as the loop below doesn't handle vanishing
	# elements well
	for ship in ships:
		if ship.health <= 0:
			remove_ship(ship)

	for i in range(self.multimesh.visible_instance_count):
		var ship = ships[i]
		if not is_instance_valid(ship.target):
			ship.update_target(planets)
		ship.update(dt)
		multimesh.set_instance_transform_2d(i, ship.transform)

	update()

func _draw():
	for ship in ships:
		if ship.laser != null:
			draw_line(ship.transform.origin, ship.laser, Color.red, 3.0)

func remove_ship(ship):
	multimesh.visible_instance_count -= 1
	ships.erase(ship)

func add_ship(position):
	multimesh.visible_instance_count += 1
	var ship = EnemyShip.new()
	ship.init(position)
	ships.push_back(ship)
	multimesh.set_instance_transform_2d(multimesh.visible_instance_count - 1, ship.transform)
	multimesh.set_instance_color(multimesh.visible_instance_count - 1, Color.red)

func spawn_wave():
	for _i in range(enemies_to_spawn):
		add_ship(Vector2(-1920/2, -1080/2))
	enemies_to_spawn += 2

class EnemyShip:
	var transform: Transform2D
	var target: Planet
	var velocity: Vector2 = Vector2(randf() - 0.5, randf() - 0.5)
	var time_since_shot = 0
	var laser = null
	var health = 2
	const max_speed = 80
	const steering = 1.3
	const acceleration = 0.08
	const cooldown = 2

	func init(position: Vector2):
		transform = Transform2D().translated(position)

	func update(dt):
		var direction: Vector2 = velocity.normalized()
		time_since_shot += dt
		if is_instance_valid(target):
			var to_target = target.global_position - transform.origin

			# shoot the target
			if to_target.length_squared() < 2000 and time_since_shot > cooldown:
				process_target()
			else:
				direction = to_target.normalized()
		
		# remove laser beam after a while
		if laser != null and time_since_shot > 0.2:
			laser = null

		velocity = velocity.normalized().slerp(direction, steering * dt) \
			* lerp(velocity.length(), max_speed, acceleration * dt)

		var new_transform = Transform2D().rotated(velocity.angle())
		new_transform.origin = transform.origin + dt * velocity
		transform = new_transform

	func process_target():
		target.health -= 1
		time_since_shot = 0
		laser = target.global_position
		if target.health <= 0:
			target = null

	func update_target(planets):
		for planet in planets:
			if planet.building != Planet.building_type.NONE:
				target = planet
				return
