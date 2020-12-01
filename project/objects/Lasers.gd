extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.connect("fired", self, "_on_Laser_fired")
		child.connect("reloaded", self, "_on_Laser_reloaded")
		child.connect("selected", get_tree().get_root().get_node("Game"), "_on_Laser_selected")
	get_child(0).set_active()

func add_laser(which):
	for child in get_children():
		if which.position.x < child.position.x:
			move_child(which, child.get_index())
			return
		

func _on_Laser_fired(which):
	for laser in get_children():
		if laser.loaded and !laser.active and laser != which:
			laser.call_deferred("set_active")
			return
			
func _on_Laser_reloaded(which):
	for laser in get_children():
		if laser.active:
			return
	which.set_active()
