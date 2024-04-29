extends Node2D

@export var player_path : NodePath

# UNIMPORTANT SHIT
@export_category("Line Stats")
@export var limit_max := 100
@export var limit_depletion_rate := 10
@export var cable_texture : Texture2D
@export_category("Line Configuration")
@export var line_width = 16
@export var line_sharp_limit = 32
@export var line_round_precision = 32

var start_position = Vector2.ZERO
var drawing_line_preview = null
var drawing_line_final = null
var current_line = null
var pole_line_start = null
var pole_line_finish = null

@onready var close_marker = $CloseMarker
@onready var player = get_node(player_path)

func _ready():
	set_process_input(true)

func post_config(line: Line2D):
	line.width = line_width * 1.5
	line.default_color = Color("663322")
	line.default_color = Color("663322")

func line_config(current_line):
	current_line.width = line_width
	current_line.texture = cable_texture
	current_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.antialiased = true
	current_line.sharp_limit = line_sharp_limit
	current_line.round_precision = line_round_precision
	current_line.points = Geometry2D.offset_polyline(current_line.points, current_line.width / 2)

func get_closest_point(p_pos, l1_pos, l2_pos):
	var res = Geometry2D.get_closest_point_to_segment(
		p_pos,
		l1_pos, l2_pos
	)
	return res

func poste_posicion():
	# POSTE
	pole_line_start.add_point(to_global(current_line.points[0]) + Vector2(0,-50))
	pole_line_start.add_point(to_global(current_line.points[0]+Vector2(0, get_viewport().get_visible_rect().size.y)))
	pole_line_finish.add_point(to_global(current_line.points[1]) + Vector2(0,-50))
	pole_line_finish.add_point(to_global(current_line.points[1]+Vector2(0, get_viewport().get_visible_rect().size.y)))
	post_config(pole_line_start)
	post_config(pole_line_finish)
	add_child(pole_line_start)
	add_child(pole_line_finish)
	# CRINGE TERMINADO

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				var end_position = event.position
				
				start_position = event.position
				drawing_line_preview = Color(1, 1, 1)
				
				drawing_line_preview = Line2D.new()
				add_child(drawing_line_preview)
				
				drawing_line_preview.add_point(start_position)
		else:
			if event.button_index == MOUSE_BUTTON_LEFT and drawing_line_preview != null:
				var end_position = event.position
				
				pole_line_start = Line2D.new()
				pole_line_finish = Line2D.new()
				
				drawing_line_preview.add_point(end_position)
				drawing_line_final = drawing_line_preview
				drawing_line_preview = null
				
				current_line = drawing_line_final
				
				if drawing_line_final.points.size() > 1:
					drawing_line_final.remove_point(1)
				
				poste_posicion()
				
				for i in get_children():
					if i != current_line and i is Line2D:
						i.modulate = Color(0.5, 0.5, 0.5, 0.5)

func _process(delta):
	# LINE PREVIEW:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and drawing_line_preview != null:
		# Delete previous
		if has_node(drawing_line_preview.get_path()):
			remove_child(drawing_line_preview)
			drawing_line_preview.queue_free()

		drawing_line_preview = Line2D.new()
		add_child(drawing_line_preview)
		
		line_config(drawing_line_preview)
		
		drawing_line_preview.add_point(start_position)

		var mouse_position = get_local_mouse_position()
		drawing_line_preview.add_point(mouse_position)
	
	if current_line != null:
		var closest_point = get_closest_point(player.position, current_line.points[0], current_line.points[-1])
		close_marker.position = closest_point
		player.closest_point = closest_point
		player.marker_line = close_marker
		
		
	
