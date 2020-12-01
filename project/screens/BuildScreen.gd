extends Control


const data_display = preload("res://screens/StatData.tscn")
const build_objects = {
	"Cannon": preload("res://objects/Laser.tscn"),
	"Sentry": preload("res://objects/Laser.tscn"),
}

var selected = null
var new_building = null
var build_location = null

#Costs. Running out of time so we're gonna use a manager.
var costs = {
	"Cannon": 2,
	"Sentry": 2
}
var selected_type = null #This is so icky. Ew.


func update_panels(laser):
	selected = laser
	for display in $Upgrade/Vbox.get_children():
			display.visible = false
			display.queue_free()
	$Upgrade.rect_size = $Upgrade.rect_min_size
	if laser:
		for stat in laser.stats.keys():
			var new_display = data_display.instance()
			new_display.get_node("Type").text = stat
			new_display.get_node("Value").text = str(laser.stats[stat])
			if laser.stats[stat] == 4:
				new_display.get_node("Value").text = "MAX"
				new_display.remove_child(new_display.get_node("Button"))
			else:
				new_display.get_node("Button").text = "Upgrade (" + str(laser.stats[stat]) + ")"
				new_display.get_node("Button").connect("pressed", self, "_on_Update_button_pressed", [new_display])
				if laser.stats[stat] > $"../..".upgrade_points:
					new_display.get_node("Button").disabled = true
			
			$Upgrade/Vbox.add_child(new_display)
	$Upgrade.rect_size = $Upgrade.rect_min_size
	$Upgrade.rect_position.y = 360 # Shouldn't be necessary

func _on_Update_button_pressed(which):
	var cost = int(which.get_node("Value").text)
	selected.level_up(which.get_node("Type").text)
	$"../..".upgrade_points -= cost
	


func _on_NextWaveButton_pressed():
	update_panels(null)


# Yeah I duplicated a lot but I don't feel like figuring this out
func _on_CannonButton_pressed():
	var new_cannon = build_objects["Cannon"].instance()
	selected_type = "Cannon"
	new_cannon.play_mode = false
	new_cannon.building = true
	new_building = new_cannon
	build_location = get_node("/root/Game/Player/Lasers")
	new_building.connect("fired", build_location, "_on_Laser_fired")
	new_building.connect("reloaded", build_location, "_on_Laser_reloaded")
	new_building.connect("selected", get_tree().get_root().get_node("Game"), "_on_Laser_selected")
	add_child(new_cannon)
	start_building()


func _on_SentryButton_pressed():
	var new_cannon = build_objects["Sentry"].instance()
	selected_type = "Sentry"
	new_cannon.play_mode = false
	new_cannon.building = true
	new_cannon.player_controlled = false
	new_building = new_cannon
	build_location = get_node("/root/Game/Player/AI")
	new_building.connect("selected", get_tree().get_root().get_node("Game"), "_on_Laser_selected")
	add_child(new_cannon)
	start_building()
	
func start_building():
	mouse_filter = MOUSE_FILTER_STOP
	$"PlacementTip".visible = true
	hide_upgrade_window()
	
func show_upgrade_window():
	$Upgrade.visible = true
	
func hide_upgrade_window():
	$Upgrade.visible = false
	
func confirm_placement():
	$"../..".upgrade_points -= costs[selected_type]
	new_building.building = false
	Helpers.move_node(new_building, build_location)
	new_building._ready()
	new_building = null
	costs[selected_type] += 1
	deselect()
	update_new_costs($"../..".upgrade_points)
	
func deselect():
	if new_building:
		new_building.queue_free()
	new_building = null
	build_location = null
	selected_type = null
	mouse_filter = MOUSE_FILTER_IGNORE
	$"PlacementTip".visible = false
	hide_upgrade_window()
	
#This is getting so ugly! :( Should be using a master list of types...
#But only with two types implemented, the rule of three doesn't apply
func update_new_costs(current_points):
	$"BuildPanel/BuildOptions/Cannon".text = "Cannon (" + str(costs["Cannon"]) + ")"
	if costs["Cannon"] > current_points:
		$"BuildPanel/BuildOptions/Cannon".disabled = true
	else:
		$"BuildPanel/BuildOptions/Cannon".disabled = false
		
	$"BuildPanel/BuildOptions/Sentry".text = "Sentry (" + str(costs["Sentry"]) + ")"
	if costs["Sentry"] > current_points:
		$"BuildPanel/BuildOptions/Sentry".disabled = true
	else:
		$"BuildPanel/BuildOptions/Sentry".disabled = false

func _on_Game_upgrade_changed(amount):
	update_new_costs(amount)
	if selected:
		update_panels(selected)
		
func select_laser(which):
	show_upgrade_window()
	update_panels(which)


func _on_Player_control_event(event):
	if event.is_action_pressed("single_fire"):
		if new_building and new_building.legal_location():
			confirm_placement()
	elif event.is_action_pressed("all_fire"):
		deselect()
