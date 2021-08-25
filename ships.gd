extends MultiMeshInstance2D

var ships = []

func _ready():
	for i in range(self.multimesh.instance_count):
		var ship = Ship.new()
		ship.init()
		ships.push_back(ship)
		multimesh.set_instance_transform_2d(i, ships[i].transform)

func _process(dt):
	for i in range(self.multimesh.instance_count):
		var ship = ships[i]
		ship.update(dt)
		multimesh.set_instance_transform_2d(i, ship.transform)

func add_ship():
	multimesh.instance_count += 1
	var ship = Ship.new()
	ship.init()
	ships.push_back(ship)

class Ship:
	var transform

	func init():
		transform = Transform2D().translated(Vector2(500, 500))

	func update(dt):
		transform = transform.translated(Vector2(dt * 10, 0))
