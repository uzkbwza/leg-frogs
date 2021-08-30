extends Node2D

class_name Game

enum Side {
	Left = 0,
	Right = 1
}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hit_effect = preload("res://HitEffect.tscn")
export var x_pos = 100
export var y_pos = 230
export var ball_height = 190
export var ball_in_front = 10
export var ball_serve_power = 200
var started = false
export(Texture) var numbers
onready var p1 = $Frog
onready var p2 = $FrogP2
onready var ball = $Ball
var scored_side
var rng = RandomNumberGenerator.new()
var side_goals = true
var net = true
var floor_goals = false
var freestyle = false
var initiated = false
var divider = true
var winner_serves = true

var scores = {
	Side.Left: 0,
	Side.Right: 0
}
var winner = null
onready var score_sprites = {
	Side.Left: $P1Score,
	Side.Right: $P2Score
}
export var max_score = 1

# Called when the node enters the scene tree for the first time.
func start(side=null):
	if side == null:
		side = rng.randi_range(0, 2)
		print(side)
	if !initiated:
		if !side_goals:
			$Border1.hide()
			$Border2.hide()
			$Bg.hide()
			$P1OutZone/CollisionShape2D.call_deferred("set", "disabled", true)
			$P2OutZone/CollisionShape2D.call_deferred("set", "disabled", true)
			$NoSideGoalsFloor/CollisionShape2D6.call_deferred("set", "disabled", false)
			$NoSideGoalsFloor/CollisionShape2D8.call_deferred("set", "disabled", false)
		if !net:
			$Net.queue_free()
		if !divider:
			$Wall/CollisionShape2D5.call_deferred("set", "disabled", true)
			
	winner = null
	$P1Tally.frame = 0
	$P2Tally.frame = 0
	if $StartScreen.visible:
		$StartScreen.hide()
	if !freestyle or !initiated:
		var p1_position = Vector2(256 - x_pos, y_pos)
		var p2_position = Vector2(256 + x_pos, y_pos)
		var ball_position = Vector2()
		if side == Side.Left:
			ball_position = p1_position
			ball_position.x += ball_in_front
		else:
			ball_position = p2_position
			ball_position.x -= ball_in_front
		ball_position.y -= ball_height
		ball.reset(ball_position)
		p1.reset(p1_position)
		p2.reset(p2_position)
		var first_match = true
		for score in scores.values():
			if score != 0:
				first_match = false
		if first_match:
			$GameStart.play()
	#	ball.apply_central_impulse(Vector2.UP * ball_serve_power)
	#	yield(get_tree(), "idle_frame")
	#	ball.sleeping = true
		if has_node("Net"):
			$Net.reset_net(true)
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	if !freestyle or !initiated:
		ball.linear_velocity = Vector2()
		ball.angular_velocity = 0
	ball.scored = false
	initiated = true

func _ready():
	$P2Score.position = $P1Score.position
	$P2Score.position.x = 512 - $P2Score.position.x
	$StartScreen/Button.grab_focus()
#	start()
	Engine.time_scale = 1.0
	get_tree().paused = true
	rng.randomize()

func _physics_process(delta):
	if !get_tree().paused and Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	for node in [$Border1, $Border2]:
		node.offset = $Camera2D.offset / 2

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func check_oob(body):
	if $P1OutZone.overlaps_body(body):
		score(Side.Left)
		return true
	elif $P2OutZone.overlaps_body(body):
		score(Side.Right)
		return true
	return false

func score(side: int, opposite = true):
	if !ball.scored:
		ball.scored = true
		scored_side = side
		var opposite_side = (side + 1) % 2
		if opposite:
			var temp = scored_side
			scored_side = opposite_side
			opposite_side = temp
		if !freestyle:
			scores[scored_side] += 1
			Engine.time_scale = 0.25
		$FreezeTimer.start(0.25)
		$Camera2D.screenshake(0.15, -ball.dir)
		
		ball.get_node("Score").play()
	##	ball.contact_monitor = false
	#	get_tree().paused = true
		
		if !freestyle:
			if scores[scored_side] >= max_score:
				$EndGame.play()
				end_game(scored_side)
			else:
				$Score.play()
		score_sprites[scored_side].frame = scores[scored_side]

func end_game(scored_side):
	$FreezeTimer.start(0.5)
	if scored_side == Side.Left:
		winner = p1
	else:
		winner = p2
	scores = {
		Side.Left: 0,
		Side.Right: 0
	}
	for side in scores:
		score_sprites[side].frame = scores[side]
		
func hit_effect(pos, scored):
	$P1Tally.frame = ball.num_bounces if ball.last_side_hit == Side.Left else 0
	$P2Tally.frame = ball.num_bounces if ball.last_side_hit == Side.Right else 0

	if !ball.hit_effect_timer.is_stopped() and !scored:
		return
#	if frog:
#		$HitFreezeTimer.start()
#		Engine.time_scale = 0.1
	var effect = hit_effect.instance()
	if scored:
		effect.color = Color("#ff333d")
	effect.global_position = pos
	effect.dir = ball.dir.normalized()
	effect.modifier = min(1.0, ball.linear_velocity.length() / 300)
	ball.get_node("HitNormal").play()
	if effect.modifier > 0.5:
		ball.get_node("HitFast").play()	
#	print(ball.linear_velocity.length())
	call_deferred("add_child", effect)

func _on_FreezeTimer_timeout():
	get_tree().paused = false
	yield(get_tree(), "physics_frame")
	if winner_serves:
		start(scored_side)
	else:
		start((scored_side + 1) % 2)
	Engine.time_scale = 1.0
#	ball.contact_monitor = true
#	pass # Replace with function body.

func _on_HitFreezeTimer_timeout():
	Engine.time_scale = 1.0


func _on_Button_pressed():
	start()
	get_tree().paused = false
	started = true


func _on_CheckBox_toggled(button_pressed):
	p2.ai = button_pressed
	_on_Button_pressed()


func _on_VsAi_pressed():
	p2.ai = true
	_on_Button_pressed()


func _on_SideGoals_toggled(button_pressed):
	for node in [$Border1, $Border2, $Bg]:
		node.visible = button_pressed
	side_goals = button_pressed


func _on_Net_toggled(button_pressed):
	$Net.visible = button_pressed
	net = button_pressed
	pass # Replace with function body.


func _on_FreestyleMode_toggled(button_pressed):
	freestyle = button_pressed
	$P1Score.visible = !button_pressed
	$P2Score.visible = !button_pressed
	$P1Tally.visible = !button_pressed
	$P2Tally.visible = !button_pressed
	$StartScreen/Divider.disabled = !button_pressed
	if !button_pressed:
		$StartScreen/Divider.pressed = true
#	_on_SideGoals_toggled(!button_pressed)
	pass # Replace with function body.


func _on_Divider_toggled(button_pressed):
	$Divider.visible = button_pressed
	divider = button_pressed
	pass # Replace with function body.


func _on_WinnerServes_toggled(button_pressed):
	winner_serves = button_pressed
	pass # Replace with function body.
