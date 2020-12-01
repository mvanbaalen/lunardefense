extends Node2D

signal round_end

var meteor_scene = preload("res://objects/Meteor.tscn")
var game_round = 1
var wave_end = false


## Had to add this to fix a bug but want to delete it
#func process(_delta):
#	if wave_end:
#		check_for_ending()
		

func _on_Timer_timeout():
	var new_meteor = meteor_scene.instance()
	new_meteor.position = Vector2(Helpers.random.randi_range(100,1000), -50)
	new_meteor.level = game_round
	new_meteor.connect("destroyed", self, "_on_obstacle_destroyed")
	add_child(new_meteor)

func _on_obstacle_destroyed():
	if wave_end:
		check_for_ending()
		
func check_for_ending():
	if get_child_count() <= 2+1: # The one remaining when the check is made? Dangerous...
		emit_signal("round_end")
		wave_end = false

func _on_WaveProgress_timeout():
	$Timer.stop()
	$Timer2.stop()
	wave_end = true
	check_for_ending()

func _on_NextWaveButton_pressed():
	$Timer.start()
	$Timer2.start()
	game_round += 1 
	wave_end = false

func get_closest_obstacle():
	var closest_obstacle = null
	var closest_location = 0
	var all_obstacles = get_children().slice(2, get_child_count())
	if all_obstacles.size() > 0:
		for obstacle in all_obstacles:
			if obstacle.position.y > closest_location and !obstacle.targeted:
				closest_location = obstacle.position.y
				closest_obstacle = obstacle
		if !closest_obstacle:
			closest_obstacle = all_obstacles[0]
		closest_obstacle.targeted = true
	return closest_obstacle
