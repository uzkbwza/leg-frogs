extends RigidBody2D

class_name Ball

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var push_speed = 10
var radius
var last_side_hit = Game.Side.Left
var queued_reset_pos = null
var prev_pos = Vector2()
var dir = Vector2()
var scored = false
signal hit(pos, scored)
var num_bounces = 0
var hit_effect = false
var can_hit_effect = true
var hit_point = Vector2()
onready var hit_effect_timer = $HitEffectTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("hit", get_parent(), "hit_effect")
	radius = $CollisionShape2D.shape.radius
	can_hit_effect = true
	connect("hit", self, "hit_timer")
	pass # Replace with function body.

func hit_timer(_ignore, _ignore2):
	hit_effect_timer.start()

func _integrate_forces(state):
	if queued_reset_pos:
		state.transform.origin = queued_reset_pos
		queued_reset_pos = null
		if global_position.x > 256:
			last_side_hit = Game.Side.Right
		else:
			last_side_hit = Game.Side.Left
	if state.get_contact_count():
		var contact = state.get_contact_collider_position(0)
		if contact:
			hit_point = (contact)
	dir = (global_position - prev_pos)
	prev_pos = global_position
	update()
	
func _process(delta):
	if queued_reset_pos:
		set_sleeping(true)

func _on_Ball_body_entered(body):
#	emit_signal("hit", global_position)
	yield(get_tree(), "physics_frame")
	if body is BallHitter:
		apply_impulse(to_local(body.global_position), ((Vector2(cos(body.angle), sin(body.angle)) + (global_position - body.global_position).normalized()) / 2) * push_speed)
		last_side_hit = body.side
		emit_signal("hit", hit_point, false)
	elif body.is_in_group("bounds"):
		var new_side_hit
		if global_position.x > 256:
			new_side_hit = Game.Side.Right
		else:
			new_side_hit = Game.Side.Left
		if new_side_hit != last_side_hit:
			num_bounces = 0
		if body.is_in_group("floor"):
			num_bounces += 1
			if num_bounces > 2:
				emit_signal("hit", global_position, true)
				get_parent().score(last_side_hit, true)
			if num_bounces < 4:
				[$Bounce1, $Bounce2, $Bounce3][num_bounces - 1].play()
		last_side_hit = new_side_hit
		if !scored:
			if get_parent().check_oob(self):
				emit_signal("hit", hit_point, true)
			else:
				emit_signal("hit", hit_point, false)
		else:
			emit_signal("hit", hit_point, false)
	elif body.is_in_group("net"):
		if !scored:
			get_parent().score(last_side_hit, true)
		if can_hit_effect:
			emit_signal("hit", hit_point, true)
		can_hit_effect = false
	else:
		emit_signal("hit", hit_point, false)

func reset(pos):
	num_bounces = 0
	queued_reset_pos = pos

#func _draw():
#	draw_line(Vector2(), (dir * 10).rotated(-rotation), Color.blue, 2)
#	draw_line(Vector2(), (dir * 10), Color.green, 2)
