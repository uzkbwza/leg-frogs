extends KinematicBody2D

class_name KinematicObject

export(float) var gravity = 0
export(float) var friction = 0
export(float) var angular_fric = 0.045

var angular_accel = 0
var angular_vel = 0
var vel = Vector2(0, 0)
var prev_vel = vel
var accel = Vector2(0, 0)
var speed = 0
var impulses = Vector2()
var prev_speed = 0
var prev_accel = Vector2()
export var max_turn_speed = 0
export var max_speed = 0
	
func apply_forces(delta, vertical_fric=false):
#	var fraction = Engine.get_physics_interpolation_fraction()
	prev_vel = vel
	#	print(just_jumped)
	vel.x -= friction * sign(vel.x) * delta
	if vertical_fric:
		vel.y -= friction * sign(vel.y) * delta
	apply_force(Vector2(0, gravity))
	
	prev_speed = speed
	
	vel += impulses
	vel += accel * delta
	
	if max_speed:
		vel = vel.clamped(max_speed)
#	global_position = LevelManager.clamp_to_bounds(global_position)
	vel = move_and_slide(vel)
	speed = vel.length()

	prev_accel = accel
	accel = Vector2(0, 0)
	impulses = Vector2(0, 0)
	_turn(delta)
	rotate(angular_vel * delta)

func apply_forces_simple(delta):
#	var fraction = Engine.get_physics_interpolation_fraction()
	#	print(just_jumped)
	vel.x -= friction * sign(vel.x) * delta
	apply_force(Vector2(0, gravity))
	
	vel += accel * delta
	vel += impulses
	
	if max_speed:
		vel = vel.clamped(max_speed)
	
	move_directly_simple(vel)
	accel = Vector2(0, 0)
	impulses = Vector2(0, 0)
	_turn(delta)
	rotate(angular_vel * delta)
	
func move_directly(v):
	move_and_slide(v)
	speed = vel.length()

func move_directly_simple(v):
	vel = move_and_slide(v, Vector2.UP, false)

func rotate_directly(r, delta):
	rotation += r * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func move_in_dir(f: Vector2):
	if !f.length():
		return
	apply_force(f)

#func _process(delta):
#	pass

func get_target_angle(pos, offset=0):
#	Debug.dbg("target", cursor.global_position)
#	if cursor.locked_on:
#		target = get_angle_to(cursor.lock_on_cursor.global_position) + TAU/4
#	else:	
	var target = get_angle_to(pos) + offset
	target = target if abs(target) < PI else target + TAU * -sign(target)
	return target

func apply_force(f: Vector2):
	accel += f

func apply_impulse(f: Vector2):
	impulses += f

func apply_force_angular(f: float):
	angular_accel += f

func accel_towards(object: Node2D, accel_speed: float):
	apply_force((object.global_position - global_position).normalized() * accel_speed)

func _turn(delta):
	angular_vel += angular_accel
	angular_vel = clamp(angular_vel, -max_turn_speed, max_turn_speed)
	angular_vel *= pow(angular_fric, delta)
	angular_accel = 0
