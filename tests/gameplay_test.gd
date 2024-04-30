extends Node2D

signal game_over

var level = 0
var game_over_flag : = false

@onready var gameplay_redefined = $GameplayRedefined
@onready var player = $Player

func _physics_process(delta):
	var screen_size = get_viewport().get_visible_rect().size
	var player_position = player.global_position

	var is_inside_screen = (
		player_position.x >= 0 and
		player_position.x <= screen_size.x and
		player_position.y >= 0 and
		player_position.y <= screen_size.y
	)

	if not is_inside_screen and !game_over_flag:
		game_over_flag = true
		emit_signal("game_over")
