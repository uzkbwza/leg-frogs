extends Node

class_name StateInterface

# State interface for StateMachine
onready var state_name = name
var host
var active = false

func _enter_tree():
	host = get_parent().host

func enter():
	# Initialize state 
	pass

func update(_delta):
	#  To use with _process(delta)
	pass
	
func integrate(_state):
	# To use with _integrate_forces(state)
	pass

func exit():
	#  Cleanup and exit state
	pass
