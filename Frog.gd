extends RigidBody2D

class_name Frog
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var min_spring_length = 0
export var max_spring_length = 10
export(Color) var leg_color
export(Game.Side) var side = Game.Side.Left
#export var max_angular_velocity = 1

onready var left_foot = $LFoot
onready var right_foot = $RFoot
onready var left_hip_collider = $LeftHipCollider
onready var left_knee_collider = $LeftKneeCollider
onready var right_hip_collider = $RightHipCollider
onready var right_knee_collider = $RightKneeCollider
var left_knee: Vector2
var right_knee: Vector2
var left_hip: Vector2
var right_hip: Vector2
export var fric = 0.25
export var angular_fric = 0.65
var queued_reset_pos = null
var ai = false

func _process(delta):
	update()


func _integrate_forces(state):
	for foot in [left_foot, right_foot]:
		if !foot.contracted and foot.ratio > 0:
	#		var a = min(abs(angular_velocity), max_angular_velocity)
	#		angular_velocity = a * sign(angular_velocity)
			var sideways = linear_velocity.rotated(-rotation).x
			linear_velocity -= Vector2(sideways * friction, 0).rotated(rotation)
			angular_velocity -= angular_fric * angular_velocity
	#		var global_direction = global_transform.basis.xform(relOffset)
	if queued_reset_pos:
		state.linear_velocity = Vector2()
		state.angular_velocity = 0
		rotation = 0
#		state.transform.origin = queued_reset_pos
		state.transform = Transform2D(0, queued_reset_pos)
		queued_reset_pos = null
#		queued_reset_rotation = true

func _physics_process(delta):
	var left_leg = get_leg(left_foot)
	left_knee = left_leg[0]
	left_hip = left_leg[1]	
	var right_leg = get_leg(right_foot)
	right_knee = right_leg[0]
	right_hip = right_leg[1]
	position_colliders(left_hip_collider, left_knee_collider, left_foot, left_hip, left_knee)
	position_colliders(right_hip_collider, right_knee_collider, right_foot, right_hip, right_knee)
	right_hip_collider.rotation -= TAU/4
		
func toggle_both(toggle):
	left_foot.toggle(toggle)
	right_foot.toggle(toggle)
	
func check_touching_ground():
	for foot in [left_foot, right_foot]:
		if foot.get_ratio() > 0:
			return true
	return false

func cpu_process():
	var ball = get_parent().ball
	if ball.global_position.y < global_position.y - 100:
		toggle_both(false)
	elif abs(ball.global_position.y - global_position.y) < 40:
		if !check_touching_ground():
			if ball.position.x > position.x:
				left_foot.toggle(true)
			else:
				right_foot.toggle(true)
		else:
			if ball.position.x < position.x:
				left_foot.toggle(true)
			else:
				right_foot.toggle(true)
#	else:
#		toggle_both(true)

#	elif get_parent().rng.randi_range(0, 100) < 20:
#		left_foot.toggle(true)
#	elif get_parent().rng.randi_range(0, 100) < 20:
#		right_foot.toggle(true)
		




func position_colliders(hip_collider, knee_collider, foot, hip, knee):
	var foot_pos = to_local(foot.sprite.global_position)
	hip_collider.position = lerp(hip, knee, 0.5)
	hip_collider.rotation = hip.angle_to(knee) + TAU/8
	knee_collider.position = lerp(knee, foot_pos, 0.5)
	knee_collider.rotation = knee.angle_to(foot_pos)

func _draw():
	draw_foot(left_foot, left_hip, left_knee)
	draw_foot(right_foot, right_hip, right_knee)

func get_leg(foot):
	var knee_base = 5
	var knee_width = 11
	var s = -1 if foot.left else 1
	var hip = foot.position - Vector2(1 * s, 4)
	var knee = Vector2(knee_base * s, to_local(foot.sprite.global_position).y/2)
	knee.x += knee_width * (1 - (foot.actual_length / foot.max_length)) * s
	return [knee, hip]
	
func draw_foot(foot, hip, knee):
	
	draw_line(hip, knee, leg_color, 5, false)
	draw_circle(knee, 2, leg_color)
	draw_line(knee, to_local(foot.sprite.global_position), leg_color, 3, false)

func reset(pos):
	toggle_both(true)
	queued_reset_pos = pos
	if ai:
		$AiCycle.start()

func _on_AiCycle_timeout():
	cpu_process()
	pass # Replace with function body.
