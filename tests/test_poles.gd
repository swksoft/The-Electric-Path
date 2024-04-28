extends Node2D

var pole_start = Line2D
var pole_finish = Line2D
var pole = Line2D

@onready var line_2d = $Line2D

func _ready():
	pole = Line2D.new()
	var pole2 = Line2D.new()
	
	pole.default_color = Color("663322")
	
	pole.add_point(to_global(line_2d.points[0]) + Vector2(0,-50))
	pole.add_point(to_global(line_2d.points[0]+Vector2(0, get_viewport().get_visible_rect().size.y)))
	
	add_child(pole)
	
	pole2.add_point(to_global(line_2d.points[-1]) + Vector2(0,-50))
	pole2.add_point(to_global(line_2d.points[-1]+Vector2(0, get_viewport().get_visible_rect().size.y)))
	
	add_child(pole2)
