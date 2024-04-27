extends Node2D

var segment_start : Vector2
var segment_finish : Vector2
var grab = false

@onready var player = $Player
@onready var player_pol = $Player/Polygon2D
@onready var line = $Line2D
@onready var result = $Marker2D

func _ready():
	segment_start = line.to_global(line.points[0])
	segment_finish = line.to_global(line.points[1])
	prints(segment_start, segment_finish)

func _physics_process(delta):
	print(player.linear_velocity)
	
	if result.global_position == segment_finish or result.global_position == segment_start:
		return
	
	var res = Geometry2D.get_closest_point_to_segment(
		player_pol.global_position,
		line.to_global(line.points[0]), line.to_global(line.points[1])
	)
	
	var dis = player.global_position.distance_to(res)
	
	result.global_position = res
	
	if dis <= 20 and player.global_position != line.points[0]:
		grab = true
		player.global_position = result.position
	
