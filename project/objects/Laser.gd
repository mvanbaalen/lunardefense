extends Node2D

const laser_sprites = {
	1: preload("res://objects/lasers/Laser1.tscn"),
	2: preload("res://objects/lasers/Laser2.tscn"),
	3: preload("res://objects/lasers/Laser3.tscn"),
	4: preload("res://objects/lasers/Laser4.tscn")
}

signal fired(who)
signal reloaded(who)
signal selected(who)

const ACTIVE_COLOR = Color.white
const LOAD_COLOR = Color.darkgray

var bullet_scene = preload("res://objects/Bullet.tscn")

var aim_location
var loaded = true
var line_color = LOAD_COLOR
var line_width = 1.0
var play_mode = true
export var active = false

#Consider moving to composition
export var initial = false
export var player_controlled = true
var building = false

#Stats
var stats = {
	#"Bullet Type": "Ballistic",
	"Number of Bullets": 1,
	"Reload Speed": 1,
	"Bullet Speed": 1,
	"Bullet Power": 1,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	if player_controlled and !building:
		aim_location = get_node("../../Reticle")
		if !initial:
			get_parent().add_laser(self)
	else:
		aim_location = null
	
func _process(_delta):
	if play_mode:
		if player_controlled:
			$Sprite.rotation = position.angle_to_point(aim_location.position) - PI/2
		else:
			if aim_location and !aim_location.dead:
				$Sprite.rotation = position.angle_to_point(aim_location.position) - PI/2
			else:
				get_target()
	else:
		$Sprite.rotation = 0
		if building:
			position.x = clamp(get_global_mouse_position().x, 120, 1150)
			position.y = 670
	$ProgressBar.value = Helpers.percent_from_timer($Reload)
	update()

func _draw():
	if play_mode and player_controlled:
		draw_line($Sprite.position, aim_location.position - position, line_color, line_width)
	
func vector_to_aim():
	return aim_location.position - position
	
func fire():
	if loaded and (active or !player_controlled):
		for barrel in $Sprite/Barrels.get_children():
			var new_bullet = bullet_scene.instance()
			new_bullet.position = barrel.global_position
			new_bullet.velocity = aim_location.position - position
			new_bullet.speed_level = stats["Bullet Speed"]
			new_bullet.power_level = stats["Bullet Power"]
			get_parent().get_parent().add_child(new_bullet)
		loaded = false
		set_inactive()
		$Reload.wait_time = 2.5 - (stats["Reload Speed"] * .5)
		$Reload.start()
		$Sprite/AnimationPlayer.play("shoot")
		$AudioStreamPlayer2D.play()
		emit_signal("fired", self)


func _on_Reload_timeout():
	loaded = true
	emit_signal("reloaded", self)
	if !player_controlled and aim_location:
		fire()
	
func set_active():
	active = true
	line_color = ACTIVE_COLOR
	line_width = 2.0
	
func set_inactive():
	active = false
	line_color = LOAD_COLOR
	line_width = 1.0
	
func level_up(stat):
	match stat:
		"Reload Speed":
			stats[stat] += 1
		"Bullet Speed":
			stats[stat] += 1
		"Bullet Power":
			stats[stat] += 1
		"Number of Bullets":
			stats[stat] += 1
			change_sprite(laser_sprites[stats[stat]])
	return stats[stat]
	

func change_sprite(new_sprite):
	var old_node = $Sprite
	var new_node = new_sprite.instance()
	var index = old_node.get_index()
	remove_child(old_node)
	add_child(new_node) 
	move_child(new_node, index)
	
func get_target():
	var new_target = $"../../../Obstacles".get_closest_obstacle()
	if new_target:
		aim_location = new_target
		fire()
	else:
		return null


func legal_location():
	return $Clickable.get_overlapping_areas().size() == 0

func _on_Clickable_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("single_fire"):
		if !play_mode and !building:
			emit_signal("selected", self)


func _on_Clickable_mouse_entered():
	if !play_mode and !building:
		$Holder.modulate = Color.green
		$Sprite.modulate = Color.green

func _on_Clickable_mouse_exited():
	if !play_mode and !building:
		$Holder.modulate = Color.white
		$Sprite.modulate = Color.white


func _on_Clickable_area_entered(_area):
	if building:
		$Holder.modulate = Color.red
		$Sprite.modulate = Color.red


func _on_Clickable_area_exited(_area):
	if building:
		$Holder.modulate = Color.white
		$Sprite.modulate = Color.white
