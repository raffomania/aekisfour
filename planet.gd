extends Node2D

enum building_type {RESOURCE, SHIPYARD, NONE}

var resources = 0
var selected = false
var show_label = false
var character
var building = building_type.NONE

const radius = 20
const font = preload('res://mono.tres')
const ship_texture = preload('res://ship.svg')

func _ready():
	add_to_group('planets')

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.teal)

	if selected:
		var offset = radius + 10 
		draw_line(Vector2(offset, offset), Vector2(offset, offset / 2), Color.white)
		draw_line(Vector2(offset, offset), Vector2(0, offset), Color.white)
		draw_line(Vector2(-offset, -offset), Vector2(-offset, -offset / 2), Color.white)
		draw_line(Vector2(-offset, -offset), Vector2(0, -offset), Color.white)

	if show_label:
		var pos = Vector2(-15, radius + 30)
		var char_string = OS.get_scancode_string(character)
		pos.x += draw_char(font, pos, '[', char_string) + 2
		pos.x += draw_char(font, pos, char_string, ']') + 2
		var _next = draw_char(font, pos, ']', '')

	if building == building_type.RESOURCE:
		draw_circle(Vector2(0, 0), radius - 10, Color.white)

	for i in range(resources):
		var position = Vector2(radius + 5, 0).rotated(i * TAU / 20)
		draw_circle(position, 2, Color.beige)

	if building == building_type.SHIPYARD:
		draw_texture(ship_texture, Vector2(-5, -5))


func _process(_delta):
	update()

func tick_resources():
	resources += 1
	update()

func set_building(type):
	if building != building_type.NONE:
		return

	building = type
	if type == building_type.RESOURCE:
		var resource_timer = Timer.new()
		resource_timer.wait_time = 5
		resource_timer.connect('timeout', self, 'tick_resources')
		add_child(resource_timer)
		resource_timer.start()
