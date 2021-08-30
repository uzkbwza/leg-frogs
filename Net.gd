extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var base = $NetBase
onready var end = $NetEnd
onready var net_top = $NetTop.position
onready var net_bottom = $NetBottom.position
var colliding = false
var collision
var collision_point
export(Color) var net_color
var relative_to_net_point
onready var net_rest_pos = end.global_position
var hit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var colliders = end.get_colliding_bodies()

	if colliders:
		hit_net()
		collision = colliders[0]
		var local = to_local(collision.global_position)
		collision_point = local
		if collision is Ball:
			relative_to_net_point = (end.global_position - collision.global_position).normalized() * collision.radius
			collision_point = local + relative_to_net_point
		colliding = true
	elif (end.global_position - net_rest_pos).length() < 0.01:
		reset_net()
	update()

func hit_net():
	if !hit:
		hit = true
		$NetEnd/TopCatcher.disabled = false
		$NetEnd/BottomCatcher.disabled = false
	pass

func reset_net(force=false):
	if hit or force:
		hit = false
		$NetEnd/TopCatcher.disabled = true
		$NetEnd/BottomCatcher.disabled = true

func _draw():
	if hit:
		if colliding:
			var collision_point_top = collision_point - Vector2(0, collision.radius)
			var collision_point_bottom = collision_point + Vector2(0, collision.radius)
			draw_line(net_top, collision_point_top, net_color, 3)
			draw_line(collision_point_top, collision_point_bottom, net_color, 3)
			draw_line(collision_point_bottom, net_bottom, net_color, 3)
		else:
			draw_line(net_top, end.position, net_color, 3)
			draw_line(collision_point, end.position, net_color, 3)
