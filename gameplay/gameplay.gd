@icon("res://path/to/class/icon.svg")
extends Node2D

signal done_line

# UNIMPORTANT SHIT
@export var player_path : NodePath
@export_category("Line Stats")
@export var limit_max := 100
@export var limit_depletion_rate := 10
@export var cable_texture : Texture2D
@export_category("Line Configuration")
@export var line_width = 16
@export var line_sharp_limit = 32
@export var line_round_precision = 32

var current_line: Line2D
var marker_line: Marker2D
var pressed := false
var limit : int
var player

@onready var lines = $Lines
@onready var markers = $Markers

func _ready():
	player = get_node(player_path)
	limit = limit_max
	
	#print_rich("[color=RED][pulse] GOR DOWN [/pulse]")

func delete_all():
	var select_lines = lines.get_children()
	
	if select_lines != []:
		for i in lines.get_children():
			i.queue_free()
		for i in markers.get_children():
			i.queue_free()

func _input(event):
	if event is InputEventMouseButton:
		pressed = event.pressed
		
		if pressed and !limit <= 0:
			current_line = Line2D.new()
			marker_line = Marker2D.new()
			
			# NADA IMPORTANTE
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
			
			lines.add_child(current_line)
	
	if event is InputEventMouseMotion && pressed && !limit <= 0:
		current_line.add_point(event.position)
		
func _process(delta):
	var lines_children = get_tree().get_nodes_in_group("LineGroup")
	
	print(lines_children)
	
	if Input.is_action_pressed("click") and InputEventMouseMotion: # TODO: NO PUEDO DETECTAR QUE SOLO SE DRENE CUANDO MOVES EL MOUSE
		limit -= limit_depletion_rate * delta
	elif Input.is_action_just_released("click"):
		emit_signal("done_line")
	elif Input.is_action_just_pressed("restart") and OS.is_debug_build():
		limit = limit_max
		delete_all()
		
	if markers.get_children().size() == 0 or get_node_or_null(player_path) == null or lines_children.size() == 0: return
	else:
		print(markers.get_children().size())
		for i in markers.get_children().size():
			var res = Geometry2D.get_closest_point_to_segment(
					player.global_position,
					lines_children[i].to_global(lines_children[i].points[0]), lines_children[i].to_global(lines_children[i].points[-1]), 
				)
				
			var dis = player.global_position.distance_to(res)
			
			markers.get_child(i).global_position = res
			
			# IF PLAYER NEAR POLYGON
			player.is_grabing = dis <= 20 and player.global_position and !(marker_line.global_position == lines_children[i].to_global(lines_children[i].points[1]) or marker_line.global_position == lines_children[i].to_global(lines_children[i].points[0]))
			if dis <= 20 and player.global_position and !(marker_line.global_position == lines_children[i].to_global(lines_children[i].points[1]) or marker_line.global_position == lines_children[i].to_global(lines_children[i].points[0])):
				#player.global_position = marker_line.position
				player.is_grabing = true
				pass
			

func _on_done_line():
	var sprite_debug = Sprite2D.new()
	
	if !limit <= 0 and !pressed:
		marker_line.global_position = current_line.points[0]
		
		#DEBUG
		sprite_debug.texture = cable_texture
		sprite_debug.scale /= 4
		marker_line.add_child(sprite_debug)
		
		markers.add_child(marker_line)
		#for i in current_line.points.size() - 1:
		#	return
	
		current_line.add_to_group("LineGroup")
