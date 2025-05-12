#inventory screen bounds -> an overcomplicated way to set screen bounds for the inventory
#im sure there is a much easier way to implement 2D screen borders 

extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size = get_viewport_rect().size
	$Bottom.position = Vector2(size.x/2, size.y)
	$Bottom.get_node("CollisionShape2D").shape.normal = Vector2(0, -1)
	$Right.position = Vector2(size.x, size.y/2)
	$Right.get_node("CollisionShape2D").shape.normal = Vector2(-1, 0)
	$Left.position = Vector2(0, size.y/2)
	$Left.get_node("CollisionShape2D").shape.normal = Vector2(1, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
