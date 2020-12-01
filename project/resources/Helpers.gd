extends Node

var random

func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

func percent_from_timer(timer: Timer):
	return 100 - ((timer.time_left / timer.wait_time) * 100)

func move_node(child: Node, new_parent: Node):
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.add_child(child)
