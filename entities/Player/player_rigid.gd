extends RigidBody2D

var col_on := false

func _process(delta):
	$CollisionShape2D.disabled = col_on
