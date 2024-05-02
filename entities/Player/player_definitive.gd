extends Marker2D

const MAX_SPEED = 1000

@export var radius: float = 10.0
@export var current_cable_path: NodePath

enum PlayerState {
	OUTSIDE_LINE,
	INSIDE_LINE
}
var current_state := PlayerState.OUTSIDE_LINE

var new_rigid_body = null
var current_line = null
var current_speed : Vector2
var current_line_position = Vector2.ZERO
var time_on_current_line := 0.0
var max_time_on_current_line := 2.0
var reduction_factor := 0.75

# DEBUG
var line_debug_lenght := 50
@onready var line_visualization := $Line2DDebug
var last_point := Vector2.ZERO

@onready var poly = $Polygon2D
@onready var current_cable = get_node(current_cable_path)

func _ready():
	new_rigid_body = RigidBody2D.new()
	new_rigid_body.global_position = position
	
	new_rigid_body.linear_damp_mode = RigidBody2D.DAMP_MODE_COMBINE
	#new_rigid_body.linear_damp = 100
	
	# DEBUG
	new_rigid_body.linear_velocity = Vector2(500,0)
	
	get_parent().add_child.call_deferred(new_rigid_body)
	
	draw_circle_polygon(32, radius)
	
func draw_circle_polygon(points_nb: int, rad: float) -> void:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * rad)

func debug_line():
	#var velocity_direction = (current_line_position - global_position).normalized()
	var velocity_direction = (new_rigid_body.linear_velocity).normalized()
	
	line_visualization.clear_points()
	line_visualization.add_point(poly.position)
	
	line_visualization.global_position = self.position
	#last_point = poly.position + velocity_direction * line_debug_lenght
	last_point = poly.position + velocity_direction * line_debug_lenght
	line_visualization.add_point(last_point)

func _physics_process(delta):
	
	
	match current_state:
		PlayerState.OUTSIDE_LINE:
			debug_line()
			
			# Check if RigidBody (follow)
			if new_rigid_body != null:
				global_position = new_rigid_body.position
			
			# Check if lines
			if current_line == null:
				return
			if is_near_line(current_line_position):
				current_state = PlayerState.INSIDE_LINE
			
		PlayerState.INSIDE_LINE:
			# Save current speed
			current_speed = new_rigid_body.linear_velocity
			
			var condition1 = round(global_position) == round(current_cable.current_line.points[0])
			var condition2 = round(global_position) == round(current_cable.current_line.points[-1])
			
			# Timer
			start_timer(delta)
			
			if time_out():
				release()
			else:
				if !condition1 and !condition2:
					# SIGUE CAMINO DEL CABLE
					global_position = current_line_position
				else:
					# SE SUELTA
					release()
				
				# TODO: Add physics

func is_near_line(line_position):
	return global_position.distance_to(line_position) < 20
			
func start_timer(delta):
	# ???
	if current_line == null:
		PlayerState.OUTSIDE_LINE
		
	time_on_current_line += delta
	
	#new_rigid_body.linear_velocity *= speed_reduction_factor
	if time_on_current_line >= 0.3:
		## Calcula el factor de reducción de velocidad en función del tiempo acumulado
		#var reduction_percentage = clamp(time_on_current_line / max_time_on_current_line, 0.0, 1.0)
		#var current_reduction = (1.0 - reduction_percentage) * reduction_factor

		new_rigid_body.linear_damp += 0.05
		
		#var reduction_percentage = delta / max_time_on_current_line
		#var current_reduction = (1.0 - reduction_percentage) * reduction_factor
		#new_rigid_body.linear_velocity *= current_reduction

func time_out():
	if time_on_current_line >= max_time_on_current_line:
		
		#current_speed = Vector2.ZERO
		return true
		time_out()

func release():
	time_on_current_line = 0
	
	current_line = null
	current_state = PlayerState.OUTSIDE_LINE
	current_cable.is_used = true
	
	# Delete previus RigidBody
	get_parent().get_child(3).queue_free()
	# TODO: lo de arriba

	create_rigid_body()

func create_rigid_body():
	new_rigid_body = RigidBody2D.new()
	
	new_rigid_body.global_position = position
	#new_rigid_body.linear_velocity = current_speed/1.5
	new_rigid_body.apply_force(current_speed*10)
	#new_rigid_body.linear_velocity = current_cable.current_line.points[-1] # ESTABA BIEN
	new_rigid_body.linear_velocity = current_speed
	
	
	get_parent().add_child.call_deferred(new_rigid_body)
	
func _on_gameplay_redefined_new_line():
	current_state = PlayerState.OUTSIDE_LINE
