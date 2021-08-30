extends Camera2D

onready var tween = $Tween

export var screenshake_amount = 2
var current_screenshake = 0
var rng = RandomNumberGenerator.new()
var dir = Vector2()

func screenshake(length, dir):
	tween.interpolate_property(self, "current_screenshake", 1, 0, length)
	tween.start()
	self.dir = dir
	
func _physics_process(delta):
#	var angle = rng.randf_range(0, TAU)
	offset = rng.randf_range(screenshake_amount * current_screenshake * 0.225, screenshake_amount * current_screenshake) * dir
#	dir = -dir
