extends Node2D

@export var limit := 100
@export var limit_depletion_rate := 10

var current_line: Line2D
var pressed := false

@onready var lines = $Lines

func _input(event):
	if event is InputEventMouseButton:
		pressed = event.pressed
		
		if pressed:
			current_line = Line2D.new()
			lines.add_child(current_line)
	
	if event is InputEventMouseMotion && pressed && limit > 0:
		current_line.add_point(event.position)

func _process(delta):
	if Input.is_action_pressed("click"):
		limit -= limit_depletion_rate * delta
		print(limit)
