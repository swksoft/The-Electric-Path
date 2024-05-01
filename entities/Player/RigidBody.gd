extends RigidBody2D

const MAX_SPEED = 1000

func _integrate_forces(state):
	var len = min(MAX_SPEED, state.linear_velocity.length())
	state.linear_velocity = state.linear_velocity.normalized() * len
