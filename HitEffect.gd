extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var tween = $Tween
var amount = 0
var time = 0.75
var on = false
onready var rng = get_parent().rng

var num_lines = 30
var dir
var modifier = 1.0
var min_width = 1
var max_width = 4
var start_distance = 3
var min_distance = 2
var max_distance = 10
export var color = Color("#fffafa")
var max_length = 4
var min_length = 0.5
var angles = []
var lengths = []
var distances = []
var widths = []
func hit():
	tween.interpolate_property(self, "amount", 0, 1, time,Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	on = true
	
func _ready():
	for i in range(num_lines):
		var angle
		var probability = rng.randi_range(0, 100)
		if probability < 45 and probability >= 10:
			lengths.append(rng.randf_range(min_length, max_length))
			distances.append(rng.randf_range(min_distance, max_distance))
			widths.append(rng.randf_range(min_width, max_width))
			angle = rng.randf_range(-TAU/4, TAU/4)
		elif probability < 10:
			angle = rng.randf_range(-TAU/20, TAU/20)
			distances.append(rng.randf_range(min_distance*2, max_distance*2))
			lengths.append(rng.randf_range(min_length*2, max_length*2))
			widths.append(rng.randf_range(min_width*2, max_width*2))
		else:
			angle = rng.randf_range(0, TAU)
			distances.append(rng.randf_range(min_distance/2, max_distance/2))
			lengths.append(rng.randf_range(min_length/2, max_length/2))
			widths.append(rng.randf_range(min_width/2, max_width/2))
		angles.append(Vector2(cos(angle), sin(angle)))
		
	hit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if on:
		update()
		
func _draw():
	for i in range(num_lines):
		var angle = dir.rotated(angles[i].angle())
		var dist = distances[i]
		var start = (dist + start_distance) * angle
		var length = lengths[i]
		var width = widths[i]
		var end = (start + angle) * (max_distance - start_distance)
		var l = lerp(length, 0, amount)
		var line_end = lerp(start + angle * length, end + angle * length, amount)
		var line_start = lerp(start, line_end, amount)
		draw_line(line_start * modifier, line_end * modifier, color, width * modifier * (1 - amount))
#		draw_circle(line_end * modifier, (width/2 * modifier * (1.25)), color)
	pass

func _on_Tween_tween_all_completed():
	on = false
	queue_free()
	pass # Replace with function body.
