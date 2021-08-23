extends Node2D

var resources = 0

func _ready():
	var timer = Timer.new()
	timer.wait_time = 3
	timer.connect('timeout', self, 'add_ship')
	add_child(timer)
	timer.start()

func _process(dt):
	resources += dt

func _draw():
	draw_circle(Vector2.ZERO, 10, Color.white)

func add_ship(): 
	$'../ships'.add_ship()
