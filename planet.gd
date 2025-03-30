extends Node2D

class_name Planet

enum building_type {RESOURCE, SHIPYARD, DEFENSE, NONE}

var resources = 0: set = set_resources
var reserved_resources = 0: set = set_reserved_resources
var selected = false: set = set_selected
var character
var building = building_type.NONE: set = set_building
var health = 5: set = set_health
var resource_timer

const radius = 20
const font = preload('res://mono.tres')
const cargo_texture = preload('res://ships/cargo_ship.svg')
const defense_texture = preload('res://ships/defense_ship.svg')

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.TEAL)

	if selected:
		var offset = radius + 10
		draw_line(Vector2(offset, offset), Vector2(offset, offset / 2), Color.WHITE)
		draw_line(Vector2(offset, offset), Vector2(0, offset), Color.WHITE)
		draw_line(Vector2(-offset, -offset), Vector2(-offset, -offset / 2), Color.WHITE)
		draw_line(Vector2(-offset, -offset), Vector2(0, -offset), Color.WHITE)

	if building == building_type.RESOURCE:
		draw_circle(Vector2(0, 0), radius - 15, Color.WHITE)
	elif building == building_type.SHIPYARD:
		draw_texture(cargo_texture, Vector2(-5, -5), Color.WHITE)
	elif building == building_type.DEFENSE:
		draw_texture(defense_texture, Vector2(-5, -5), Color.WHITE)

	for i in range(resources):
		var position = Vector2(radius + 5, 0).rotated(i * TAU / 20)
		draw_circle(position, 2, Color.BEIGE)


func tick_resources():
	resources += 1
	queue_redraw()

func try_spawn_ship():
	var ships = $'../../cargo_ships'
	if building == building_type.DEFENSE:
		ships = $'../../defense_ships'
	if resources >= 5:
		ships.add_ship(self.global_position)
		resources -= 5
		queue_redraw()

func set_building(type):
	building = type
	queue_redraw()

	if type != building_type.NONE:
		# reset health in case this building was destroyed before
		health = 5

	if type == building_type.RESOURCE and not is_instance_valid(resource_timer):
		# Produce resources periodically
		resource_timer = Timer.new()
		resource_timer.wait_time = 5
		resource_timer.connect('timeout', Callable(self, 'tick_resources'))
		add_child(resource_timer)
		resource_timer.start()

	if type != building_type.RESOURCE:
		# stop producing in case this was a resource building before
		if is_instance_valid(resource_timer):
			resource_timer.queue_free()
		reserved_resources = 0

	if self.is_sink():
		# try to produce something with existing resources
		try_spawn_ship()


func set_selected(value):
	selected = value
	queue_redraw()

func set_resources(value):
	resources = value
	queue_redraw()
	if building == building_type.SHIPYARD or building == building_type.DEFENSE:
		try_spawn_ship()

func is_sink():
	return building == building_type.SHIPYARD or building == building_type.DEFENSE

func set_reserved_resources(value):
	assert(value == 0 or building == building_type.RESOURCE)
	reserved_resources = value

func set_health(new_health):
	health = new_health
	if health <= 0:
		# use `self.` to trigger setter method
		self.building = building_type.NONE
		resources = 0
