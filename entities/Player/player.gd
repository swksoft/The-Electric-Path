extends RigidBody2D

#const MASS = 1
#const GRAVITY = 1

@export var radius: float = 10.0
@export var cable_path : NodePath
@export_category("physics_parameters")
@export var max_attraction_strength  = 1000.0
@export var damping_factor = 0.5
@export var attraction_range = 200.0

var grab_position : Vector2
var stop_movement = false
var is_grabing = false
var closest_point = null
var marker_line = null
var current_velocity := Vector2.ZERO

@onready var polygon_2d = $Polygon2D
@onready var timer_grab = $TimerGrab

func _ready():
	#self.mass = MASS
	#self.gravity_scale = GRAVITY
	draw_circle_polygon(32, radius)

func draw_circle_polygon(points_nb: int, rad: float) -> void:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * rad)
	
	$Polygon2D.polygon = points

func _integrate_forces(state):
	pass

func _physics_process(delta):
	if closest_point == null or marker_line == null or cable_path == null:
		return
		
	var current_cable = get_node(cable_path)

	if !is_grabing:
		polygon_2d.self_modulate = Color("ffffffff")
		var dis = global_position.distance_to(closest_point)
		if dis < 20:
			current_velocity = linear_velocity
			is_grabing = true
	else:
		if marker_line.global_position == current_cable.current_line.points[0] or marker_line.global_position == current_cable.current_line.points[-1]:
			linear_velocity = current_velocity
			is_grabing = false
		
		timer_grab.start()
		
		polygon_2d.self_modulate = Color("ffffff00")
		polygon_2d.global_position = marker_line.position

func _on_grab_area_area_entered(area):
	print(area, " detected")

func _on_grab_area_body_entered(body):
	print(body, " detected")

func _on_timer_grab_timeout():
	is_grabing = false
