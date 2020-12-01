extends ProgressBar

signal died


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Moon_stability_changed(new_value):
	value = new_value
	if value <= 0:
		emit_signal("died")
