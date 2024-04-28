extends Node2D

@onready var player = $Entities/Player
@onready var player_polygon = $Entities/Player/Polygon2D
@onready var shape_obstacle = $Obstacles/ShapeObstacle
@onready var shape_polygon = $Obstacles/ShapeObstacle/Polygon2D


func _ready():
	print(player_polygon)

func _process(delta):
	var res_is_inside = Geometry2D.is_point_in_circle(player_polygon.global_position, shape_polygon.global_position, 40)
	print(res_is_inside)
