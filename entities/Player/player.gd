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

@onready var polygon_2d = $Polygon2D

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

func attach(state):
	if closest_point != null:
		var dis = global_position.distance_to(closest_point)
		
		if dis < 20:
			var current_velocity = linear_velocity
			polygon_2d.global_position = marker_line.position
			
			

func _integrate_forces(state):
	#state.apply_central_force()
	
	attach(state)

func _physics_process(delta):
	polygon_2d.visible = !is_grabing
	
	if closest_point != null and marker_line != null:
		var dis = global_position.distance_to(closest_point)
		
		if dis < 200:
			pass

func _on_grab_area_area_entered(area):
	print(area, " detected")

func _on_grab_area_body_entered(body):
	print(body, " detected")
