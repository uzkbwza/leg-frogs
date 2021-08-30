extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var flash_on = true

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var game = get_parent()
	if game.winner and flash_on:
		show()
		raise()
		var ang = game.rng.randf_range(0, TAU)
		rect_position = game.winner.position + Vector2.UP * 20 - rect_size / 2 + Vector2(cos(ang), sin(ang))
	else:
		hide()
	pass
	


func _on_Flash_timeout():
	flash_on = !flash_on
	pass # Replace with function body.
