extends StateInterface

func enter():
	pass

func update(delta):
	if Input.is_action_pressed(host.input_action):
		return "extended"
