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

@onready var poly = Polygon2D
@onready var current_cable = get_node(current_cable_path)

func _ready():
	new_rigid_body = RigidBody2D.new()
	new_rigid_body.global_position = position
	get_parent().add_child.call_deferred(new_rigid_body)
	draw_circle_polygon(32, radius)
	
func draw_circle_polygon(points_nb: int, rad: float) -> void:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * rad)

func _physics_process(delta):
	#var velocity_direction = (closest_point - node_position).normalized()
	
	match current_state:
		PlayerState.OUTSIDE_LINE:
			# Check if RigidBody (follow)
			if new_rigid_body != null:
				global_position = new_rigid_body.position
			
			# Check if lines
			if current_line == null:
				return
			if is_near_line(current_line_position):
				current_state = PlayerState.INSIDE_LINE
			
			#current_cable.rigid_body_position = new_rigid_body.global_position
				
			# Polygon affected by physics
			#marker_player.global_position = rigid.global_position
			
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
					
					
					#current_cable.is_used = true
					
					#new_rigid_body = RigidBody2D.new()
					#new_rigid_body.global_position = position
					
					#get_parent().add_child.call_deferred(new_rigid_body)
					
					#global_position = global_position
					
					
					#current_state = PlayerState.OUTSIDE_LINE
					
					#time_on_current_line = 0
				
				# TODO: Add physics

func is_near_line(line_position):
	return global_position.distance_to(line_position) < 20
			
func start_timer(delta):
	# ???
	if current_line == null:
		PlayerState.OUTSIDE_LINE
		
	time_on_current_line += delta

func time_out():
	if time_on_current_line >= max_time_on_current_line:
		return true
		time_out()

func release():
	time_on_current_line = 0
	
	# Delete previus RigidBody
	# TODO: lo de arriba
	
	current_line = null
	current_state = PlayerState.OUTSIDE_LINE
	current_cable.is_used = true

	create_rigid_body()

func create_rigid_body():
	new_rigid_body = RigidBody2D.new()
	new_rigid_body.global_position = position
	get_parent().add_child.call_deferred(new_rigid_body)
	
func _on_gameplay_redefined_new_line():
	current_state = PlayerState.OUTSIDE_LINE
