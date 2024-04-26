extends Node2D

@export var limit_max := 100
@export var limit_depletion_rate := 10
@export var cable_texture : Texture2D

@export_category("Line Configuration")
@export var line_width = 16
@export var line_sharp_limit = 32
@export var line_round_precision = 32

var current_line: Line2D
var pressed := false
var limit : int

@onready var lines = $Lines

# TODO: darles colisión

func _ready():
	
	
	limit = limit_max

func delete_all():
	var select_lines = lines.get_children()
	
	if select_lines != []:
		for i in lines.get_children():
			i.queue_free()

	limit = limit_max

func _input(event):
	if event is InputEventMouseButton:
		pressed = event.pressed
		
		if pressed and !limit <= 0:
			current_line = Line2D.new()
			current_line.width = line_width
			current_line.texture = cable_texture
			current_line.texture_mode = Line2D.LINE_TEXTURE_TILE
			current_line.joint_mode = Line2D.LINE_JOINT_ROUND
			current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
			current_line.antialiased = true
			current_line.sharp_limit = line_sharp_limit
			current_line.round_precision = line_round_precision
			current_line.points = Geometry2D.offset_polyline(current_line.points, current_line.width / 2)
			
			lines.add_child(current_line)
	
	if event is InputEventMouseMotion && pressed && !limit <= 0:
		current_line.add_point(event.position)

func _process(delta):
	if Input.is_action_pressed("click") and InputEventMouseMotion:
		limit -= limit_depletion_rate * delta
		print(limit)
	
	if Input.is_action_just_pressed("restart") and OS.is_debug_build():
		delete_all()
