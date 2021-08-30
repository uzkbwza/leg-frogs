extends StateInterface

func update(delta):
	if !Input.is_action_pressed(host.input_action):
		return "contracted"
