extends Marker2D

const MAX_SPEED = 1000

@export var radius: float = 10.0
@export var current_cable_path: NodePath
@export var test_trajectory : Vector2
@export var new_rigid_body_scene : PackedScene

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
var current_y_speed := 0.0
var total_distance = Vector2.ZERO
var center_path : Vector2 = Vector2.ZERO
var is_in_line := false

# DEBUG
var line_debug_lenght := 50
@onready var line_visualization := $Line2DDebug
var last_point := Vector2.ZERO

@onready var poly = $Polygon2D
@onready var current_cable = get_node(current_cable_path)
@onready var line_path = $LinePath

func _ready():
	new_rigid_body = new_rigid_body_scene.instantiate()
	
	new_rigid_body.global_position = self.global_position
	new_rigid_body.linear_damp_mode = RigidBody2D.DAMP_MODE_COMBINE
	
	get_parent().add_child.call_deferred(new_rigid_body)
	 #DEBUG
	#new_rigid_body.linear_velocity = test_trajectory

func debug_line():
	pass
	#var velocity_direction = (new_rigid_body.linear_velocity).normalized()
	#get_parent().get_child(4).add_child.call_deferred(velocity_direction)
	#
	#line_visualization.clear_points()
	#line_visualization.add_point(poly.position)
	#
	#line_visualization.global_position = self.position
	#
	#last_point = poly.position + velocity_direction * line_debug_lenght
	#line_visualization.add_point(last_point)

func path_line(delta):
	line_path.clear_points()
	line_path.add_point(center_path) # origin
	
	line_path.global_position = self.center_path
	
	var last_point = self.position
	line_path.add_point(last_point)
	
	var recorrido = line_path.points[-1] - line_path.points[0]
	total_distance += recorrido * delta

func _physics_process(delta):
	match current_state:
		PlayerState.OUTSIDE_LINE:
			debug_line()
			
			# Check if RigidBody (follow)
			if new_rigid_body != null:
				self.global_position = new_rigid_body.global_position
			
			# Check if lines
			if current_line == null:
				return
			if is_near_line(current_line_position):
				# ADD PHYSICS
				total_distance = Vector2.ZERO
				current_y_speed = new_rigid_body.linear_velocity.y
				center_path = position
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
				if (!condition1 and !condition2):
					# SIGUE CAMINO DEL CABLE
					global_position = current_line_position
					
					# LINE
					path_line(delta)
				else:
					if condition1:
						print("Sale por inicio, ", current_cable.current_line.points[0].normalized())
					elif condition2:
						print("Sale por final, ", current_cable.current_line.points[-1].normalized())
					release()
				
func is_near_line(line_position):
	if global_position.distance_to(line_position) < 50:
		# atract to cable
		new_rigid_body.apply_force(current_line_position * 0.25)
		new_rigid_body.col_on = true # blue
	return global_position.distance_to(line_position) < 20
			
func start_timer(delta):
	# ???
	if current_line == null:
		PlayerState.OUTSIDE_LINE
		
	time_on_current_line += delta
	
	if time_on_current_line <= 0.9:
		var speed_modifier = 1.01
		current_speed *= speed_modifier
	
	if time_on_current_line >= 1.0:
		new_rigid_body.linear_damp += 0.05

func time_out():
	if time_on_current_line >= max_time_on_current_line:
		return true

func release():
	time_on_current_line = 0
	
	current_line = null
	current_state = PlayerState.OUTSIDE_LINE
	current_cable.is_used = true
	
	get_parent().get_child(4).queue_free()

	create_rigid_body()

func create_rigid_body():
	new_rigid_body = new_rigid_body_scene.instantiate()
	
	new_rigid_body.global_position = position
	new_rigid_body.apply_force(total_distance * 250)
	
	get_parent().add_child.call_deferred(new_rigid_body)
	
func _on_gameplay_redefined_new_line():
	current_state = PlayerState.OUTSIDE_LINE
