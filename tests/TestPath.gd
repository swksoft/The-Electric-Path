extends Node2D

var speed = 500
var recorrido := Vector2.ZERO

@onready var player = $Player
@onready var path_follow = $Path2D/PathFollow2D
@onready var path = $Path2D

func _physics_process(delta):
	if path_follow.progress_ratio != 1:
		player.gravity_scale = 0
		speed += 600 * delta
		#path_follow.set_progress(path_follow.get_progress() + player.mass + player.linear_velocity.x + player.linear_velocity.y  * delta)
		path_follow.set_progress(path_follow.get_progress() + speed * delta)
		player.global_position = path_follow.position
		recorrido += abs(player.global_position)
		var current_point = path.curve.get_baked_points()
	else:
		player.gravity_scale = 1.5
		#player.linear_velocity = Vector2(500,-1500)
		player.linear_velocity = recorrido / speed
