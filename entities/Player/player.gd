extends RigidBody2D

const MASS = 1
const GRAVITY = 2

var stop_movement = false

func _ready():
	self.mass = MASS
	self.gravity_scale = GRAVITY
	self.freeze = stop_movement

func _draw():
	draw_circle(Vector2(0,0), 15, Color.YELLOW)
