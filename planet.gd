extends Node2D

var resources = 0
var selected = true
const radius = 10

func _ready():
	var resource_timer = Timer.new()
	resource_timer.wait_time = 5
	resource_timer.connect('timeout', self, 'tick_resources')
	add_child(resource_timer)
	resource_timer.start()
	add_to_group('planets')

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.cyan)
	for i in range(resources):
		var position = Vector2(radius + 5, 0).rotated(i * TAU / 20)
		draw_circle(position, 2, Color.beige)
	if selected:
		var offset = radius + 10 
		draw_line(Vector2(offset, offset), Vector2(offset, offset / 2), Color.white)
		draw_line(Vector2(offset, offset), Vector2(0, offset), Color.white)
		draw_line(Vector2(-offset, -offset), Vector2(-offset, -offset / 2), Color.white)
		draw_line(Vector2(-offset, -offset), Vector2(0, -offset), Color.white)

func _process(_delta):
	update()

func tick_resources():
	resources += 1
	update()
