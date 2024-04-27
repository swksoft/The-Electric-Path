extends StaticBody2D

var polygon_shape : Polygon2D

@onready var col = $CollisionShape2D
@onready var path = $Path2D

func _ready():
	var points = path.curve.get_baked_points()
	
	polygon_shape = Polygon2D.new()
	col.polygon = points
	polygon_shape.polygon = points
	add_child(polygon_shape)
	
	
