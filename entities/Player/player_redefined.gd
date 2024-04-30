extends RigidBody2D

@export var radius: float = 10.0

enum PlayerState {
	OUTSIDE_LINE,
	INSIDE_LINE
}
var current_state := PlayerState.OUTSIDE_LINE

var current_line = null
var current_line_position = Vector2.ZERO
var time_on_current_line := 0.0
var max_time_on_current_line := 2.0

func _ready():
	draw_circle_polygon(32, radius)
	
func draw_circle_polygon(points_nb: int, rad: float) -> void:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * rad)
	
	$Polygon2D.polygon = points

func _physics_process(delta):
	print(current_state)
	match current_state:
		PlayerState.INSIDE_LINE:
			time_on_current_line += delta
			attach()
			# TIME OUT
			if current_line == null:
				PlayerState.OUTSIDE_LINE
			
			if time_on_current_line >= max_time_on_current_line:
				current_line = null
				current_line_position = Vector2.ZERO
				time_on_current_line = 0
				
				current_state = PlayerState.OUTSIDE_LINE
		PlayerState.OUTSIDE_LINE:
			# If there's no lines
			if current_line == null:
				#current_state = PlayerState.OUTSIDE_LINE
				return
			# If player inputs a Line2D
			if is_near_line(current_line_position):
				current_state = PlayerState.INSIDE_LINE
				
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

func _on_gameplay_redefined_new_line():
	current_state = PlayerState.OUTSIDE_LINE
