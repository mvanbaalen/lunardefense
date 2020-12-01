extends Node2D

signal control_event(event)

enum Mode {PLAY, BUILD}

var current_mode = Mode.PLAY

func _input(event):
	if current_mode == Mode.PLAY and event.is_action_pressed("single_fire"):
		for laser in $Lasers.get_children():
			laser.fire()
	elif current_mode == Mode.BUILD:
		emit_signal("control_event", event)
		

func _on_NextWaveButton_pressed():
	$Reticle.visible = true
	current_mode = Mode.PLAY
	for laser in $Lasers.get_children():
		laser.play_mode = true
	for laser in $AI.get_children():
		laser.play_mode = true


func _on_Obstacles_round_end():
	$Reticle.visible = false
	current_mode = Mode.BUILD
	for laser in $Lasers.get_children():
		laser.play_mode = false
	for laser in $AI.get_children():
		laser.play_mode = false
