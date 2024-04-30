extends CanvasLayer

# TODO: SINCRONIZAR PROGRESS BAR CON CANTIDAD DE TRAZOS
@export var gameplay_path: NodePath
@export var player_path: NodePath
@export var level_path: NodePath

@onready var gameplay_data = get_node(gameplay_path)
@onready var player_data = get_node(player_path)
@onready var level_data = get_node(level_path)

@onready var level_label = $Control/GridContainer/LevelLabel
@onready var lines_label = $Control/GridContainer/LinesLabel
#@onready var countdown_label = $Control/CountdownLabel
@onready var timer_start = $TimerStart
#@onready var game_over_label = $Control/GameOverLabel

func _ready():
	if level_data != null and player_data != null and gameplay_data != null:
		level_label.text = "Level: " + str(level_data.level)
		lines_label.text = "Lines Left: " + str(gameplay_data.lines_left)
		
	get_tree().paused = true

func _on_button_pressed():
	get_tree().reload_current_scene()

func _on_gameplay_redefined_line_out():
	lines_label.text = "Lines Left: " + str(gameplay_data.lines_left)
	if gameplay_data.lines_left <= 0:
		lines_label.add_theme_color_override("font_color", Color.RED,)

func _process(delta):
	#if countdown_label != null:
		pass#countdown_label.text = str(int(timer_start.time_left))

func _on_timer_start_timeout():
	get_tree().paused = false
	pass#countdown_label.queue_free()

func _on_gameplay_test_game_over():
	get_tree().create_timer(1.5).timeout
	#game_over_label.visible = true
	
