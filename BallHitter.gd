extends StaticBody2D

class_name BallHitter
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var angle
var prev_position
onready var side = get_side()

func _ready():
	prev_position = global_position
	if get_parent() is Frog:
		add_collision_exception_with(get_parent())
func _physics_process(delta):
	angle = (global_position - prev_position).angle()
	prev_position = global_position
	pass

func get_side(node=self):
	if node is Frog:
		return node.side
	else:
		return get_side(node.get_parent())

func get_frog(node=self):
	if node is Frog:
		return node
	else:
		return get_frog(node.get_parent())
