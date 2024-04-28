extends RigidBody2D

const MASS = 1
const GRAVITY = 1

@export var radius: float = 12.0

var grab := false
var grab_position : Vector2
var stop_movement = false


func _integrate_forces(state):
	if grab:
		pass
		#print(linear_velocity)
		#state.transform = Transform2D(0.0, grab_position)
		#state.set_transform(Transform2D(0.0, grab_position))

func _ready():
	self.mass = MASS
	self.gravity_scale = GRAVITY
	self.freeze = stop_movement
	
	#radius *= randf_range(0.5, 1.75)
	draw_circle_polygon(32, radius)

func draw_circle_polygon(points_nb: int, rad: float) -> void:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * rad)
	
	$Polygon2D.polygon = points

#func _integrate_forces(state):
	#state.set_transform()

func _on_grab_area_area_entered(area):
	print(area, " detected")

func _on_grab_area_body_entered(body):
	print(body, " detected")
