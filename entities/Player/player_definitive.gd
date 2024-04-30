extends Node2D

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
var current_line_position = Vector2.ZERO
var time_on_current_line := 0.0
var max_time_on_current_line := 2.0

@onready var poly = $MarkerPlayer/Polygon2D
@onready var rigid = $RigidBody
@onready var current_cable = get_node(current_cable_path)
@onready var marker_player = $MarkerPlayer

func _ready():
	new_rigid_body = RigidBody2D.new()
	new_rigid_body.global_position = marker_player.global_position
	add_child(new_rigid_body)
	draw_circle_polygon(32, radius)
	
func draw_circle_polygon(points_nb: int, rad: float) -> void:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * rad)

func _physics_process(delta):
	#print(current_state)
	match current_state:
		PlayerState.OUTSIDE_LINE:
			current_cable.rigid_body_position = new_rigid_body.global_position 
			
			if new_rigid_body != null:
				current_line = null
				marker_player.global_position = new_rigid_body.position
			else:
				marker_player.global_position = new_rigid_body.position
			# Polygon affected by physics
			#marker_player.global_position = rigid.global_position
			
			# Check if no lines
			if current_line == null:
				return
			# Search for lines
			if is_near_line(current_line_position):
				current_state = PlayerState.INSIDE_LINE
			
		PlayerState.INSIDE_LINE:
			# Save current speed
			var currrent_speed = rigid.linear_velocity
			
			# Timer
			start_timer(delta)
			
			# Posicion = MarkerLine

			var condition1 = round(marker_player.global_position) == round(current_cable.current_line.points[0])
			var condition2 = round(marker_player.global_position) == round(current_cable.current_line.points[-1])
			
			if !condition1 and !condition2:
				marker_player.global_position = current_line_position
			else:
				new_rigid_body = RigidBody2D.new()
				new_rigid_body.global_position = marker_player.global_position
				
				add_child(new_rigid_body)
				
				rigid.global_position = marker_player.global_position
				rigid.linear_velocity = currrent_speed
				
				current_state = PlayerState.OUTSIDE_LINE
			
			# TODO: Add physics

func is_near_line(line_position):
	return marker_player.global_position.distance_to(line_position) < 20
			
func start_timer(delta):
	time_on_current_line += delta
	
	if current_line == null:
		PlayerState.OUTSIDE_LINE
	# TIME OUT
	if time_on_current_line >= max_time_on_current_line:
		current_line = null
		current_line_position = Vector2.ZERO
		time_on_current_line = 0
		
		current_state = PlayerState.OUTSIDE_LINE
	
func _on_gameplay_redefined_new_line():
	current_state = PlayerState.OUTSIDE_LINE
