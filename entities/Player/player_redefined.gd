extends RigidBody2D

@export var radius: float = 10.0

enum PlayerState {
	INSIDE_LINE,
	OUTSIDE_LINE
}
var current_state := PlayerState.OUTSIDE_LINE

var current_line = null
var current_line_position = Vector2.ZERO
var time_on_current_line := 0.0
var max_time_on_current_line := 3.0

func _ready():
	draw_circle_polygon(32, radius)
	
func draw_circle_polygon(points_nb: int, rad: float) -> void:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * rad)
	
	$Polygon2D.polygon = points

func _physics_process(delta):
	match current_state:
		PlayerState.INSIDE_LINE:
			time_on_current_line += delta
			if time_on_current_line >= max_time_on_current_line:
				print("Time Out")
		PlayerState.OUTSIDE_LINE:
			# SEARCH FOR LINES
			print("pass")
	
	# QUITAR
	
	# If there's no lines
	if current_line == null:
		return
	
	# If player inputs a Line2D
	if is_near_line(current_line_position):
		attach()
		time_on_current_line += delta
		# TIME OUT
		if time_on_current_line >= max_time_on_current_line:
			current_line = null
			current_line_position = Vector2.ZERO
			time_on_current_line = 0
	else:
		# Out of line
		current_line = null
		current_line_position = Vector2.ZERO
		time_on_current_line = 0
	
func is_near_line(line_position):
	return global_position.distance_to(line_position) < 20

func attach():
	print("detected")
