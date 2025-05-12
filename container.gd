extends Node2D

# Fraction of screen width the bin should occupy (0.2 = 20%)
@export var bin_width_ratio := 0.2
@export var bin_height := 100
@export var wall_thickness := 10
@export var bottom_offset := 50  # Distance above bottom of screen

func _ready():
	update_bin_geometry()

func update_bin_geometry():
	var size = get_viewport_rect().size
	var w = size.x
	var h = size.y

	var bin_width = w * bin_width_ratio
	var center_x = w / 2
	var bottom_y = h - bottom_offset
	var top_y = bottom_y - bin_height

	# Bottom wall
	$Bottom.position = Vector2(center_x, bottom_y)
	$Bottom.get_node("CollisionShape2D").shape.extents = Vector2(bin_width / 2, wall_thickness / 2)

	# Left wall
	$Left.position = Vector2(center_x - bin_width / 2, top_y + bin_height / 2)
	$Left.get_node("CollisionShape2D").shape.extents = Vector2(wall_thickness / 2, bin_height / 2)

	# Right wall
	$Right.position = Vector2(center_x + bin_width / 2, top_y + bin_height / 2)
	$Right.get_node("CollisionShape2D").shape.extents = Vector2(wall_thickness / 2, bin_height / 2)
