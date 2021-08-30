extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var left = true
export var input_action = "left_foot"
onready var tween = $Tween
export var min_length = 10
export var max_length = 20
export var extend_time = 0.1
export var p2 = false
onready var starting_pos = position
export var push_force = 1
var actual_length
onready var frog = get_parent()
var contracted = true
onready var raycast = $Raycast
var ratio = 0
export var rotation_speed = 50
onready var sprite = $Sprite

export var suspension_strength = 0.9
export var damping = 0.1

#f = -kx - bv
#Where f is the force applied to the object, k is the 'stiffness' of the spring, x is the displacement, b is the 'dampening' value, and v is the velocity. (http://gafferongames.com/game-physics/spring-physics/)

# Called when the node enters the scene tree for the first time.
func _ready():
	if !left:
		sprite.flip_h = true
	raycast.cast_to.y = min_length
	if p2:
		$Extend.pitch_scale += 1
		$Contract.pitch_scale += 1
	position_sprite()

func _physics_process(delta):
	if !get_parent().ai:
		if Input.is_action_just_pressed(input_action):
			toggle(false)
		elif Input.is_action_just_released(input_action):
			toggle(true)
	
	apply_suspension_force(delta)
	check_turnover(delta)
	position_sprite()

#	frog.apply_torque_impulse(delta * ratio * (rotation_speed if left else -rotation_speed))
	if left:
		$Label.text = str(ratio)

func check_turnover(delta):
	var rot = fmod(frog.rotation, TAU)
#	if !raycast.is_colliding() and Input.is_action_pressed(input_action) and rot > TAU/4 and rot < TAU - TAU/4:
#	if !raycast.is_colliding() and Input.is_action_pressed(input_action):
	if !contracted:
		frog.apply_torque_impulse(delta * (rotation_speed if !left else -rotation_speed))

func apply_suspension_force(delta):
	ratio = get_ratio()
	var push = Vector2.UP * push_force * ratio
#	push.x = -push.x
	frog.apply_impulse(position, (push.rotated(frog.rotation) * delta))

func position_sprite():
	if raycast.is_colliding():
		sprite.global_position = raycast.get_collision_point()
		sprite.global_rotation = raycast.get_collision_normal().angle() + TAU/4
	else:
		sprite.position = raycast.cast_to
		sprite.rotation = rotation
	actual_length = sprite.position.length()

func get_ratio():
	if !raycast.is_colliding():
		return 0.0 
	else:
		var collision_point = to_local(raycast.get_collision_point()) - position
		var raycast_length = raycast.cast_to.y
		return 1.0 - min(collision_point.length() / raycast_length, 1.0)

func toggle(contracted):
	self.contracted = contracted
	var start = Vector2()
	var end = Vector2()
	if contracted:
		$Contract.stop()
		$Extend.stop()
		$Contract.play()
		start.y = max_length
		end.y = min_length
	else:
		$Extend.stop()
		$Contract.stop()
		$Extend.play()
		start.y = min_length
		end.y = max_length
	tween.interpolate_property(raycast, "cast_to", start, end, extend_time, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

