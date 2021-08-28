extends Node2D

class_name Planet

enum building_type {RESOURCE, SHIPYARD, NONE}

var resources = 0 setget set_resources
var reserved_resources = 0 setget set_reserved_resources
var selected = false setget set_selected
var character
var building = building_type.NONE

const radius = 20
const font = preload('res://mono.tres')
const ship_texture = preload('res://ship.svg')

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.teal)

	if selected:
		var offset = radius + 10 
		draw_line(Vector2(offset, offset), Vector2(offset, offset / 2), Color.white)
		draw_line(Vector2(offset, offset), Vector2(0, offset), Color.white)
		draw_line(Vector2(-offset, -offset), Vector2(-offset, -offset / 2), Color.white)
		draw_line(Vector2(-offset, -offset), Vector2(0, -offset), Color.white)

	if building == building_type.RESOURCE:
		draw_circle(Vector2(0, 0), radius - 15, Color.white)

	for i in range(resources):
		var position = Vector2(radius + 5, 0).rotated(i * TAU / 20)
		draw_circle(position, 2, Color.beige)

	if building == building_type.SHIPYARD:
		draw_texture(ship_texture, Vector2(-5, -5))


func tick_resources():
	resources += 1
	update()

func try_spawn_ship():
	if resources >= 5:
		$'../../ships'.add_ship(self.global_position)
		resources -= 5
		update()

func set_building(type):
	if building != building_type.NONE:
		return

	building = type
	update()

	if type == building_type.RESOURCE:
		var resource_timer = Timer.new()
		resource_timer.wait_time = 5
		resource_timer.connect('timeout', self, 'tick_resources')
		add_child(resource_timer)
		resource_timer.start()

func set_selected(value):
	selected = value
	update()

func set_resources(value):
	resources = value
	update()
	if building == building_type.SHIPYARD:
		try_spawn_ship()

func set_reserved_resources(value):
	assert(value == 0 or building == building_type.RESOURCE)
	reserved_resources = value
