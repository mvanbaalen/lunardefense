extends Node2D

signal upgrade_changed(amount)

var wave = 1

func _process(_delta):
	$UI/PlayScreen/VBoxContainer2/WaveStatus.value = Helpers.percent_from_timer($WaveProgress)
	

func _on_ProgressBar_died():
	get_tree().change_scene("res://screens/GameOver.tscn")


func _on_NextWaveButton_pressed():
	wave += 1 
	$UI/BuildScreen.visible = false
	$"UI/PlayScreen/VBoxContainer2/Label".text = "Wave " + str(wave) + " Progress"
	$WaveProgress.start()

func _on_Laser_selected(laser):
	$UI/BuildScreen.select_laser(laser)


func _on_Obstacles_round_end():
	$UI/BuildScreen.visible = true
	#Round end stuff, move elsewhere
	set_upgrade(upgrade_points + 2)
	
	
#Move this stuff elsewhere later, or never if I never work on this again
var upgrade_points = 0 setget set_upgrade

func set_upgrade(new_value):
	upgrade_points = new_value
	$"UI/BuildScreen/TopPanel/VBoxContainer/PointsLabel".text = "Build Points: " + str(upgrade_points)
	emit_signal("upgrade_changed", new_value)
