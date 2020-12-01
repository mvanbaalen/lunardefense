extends Area2D

signal destroyed


var velocity = Vector2(Helpers.random.randf_range(-1, 1), 1)
var rotation_speed = 0
var move_speed = 40
var damage = 5
var level = 1

var life = 1
var dead = false

# Track if this has been targeted by AI
var targeted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Visual randomization
	$Sprite.rotation_degrees = Helpers.random.randi_range(-180,180)
	rotation_speed = Helpers.random.randi_range(-30,30)
	var size = Helpers.random.randi_range(2,8)
	
	#Sound randomization
	$AudioStreamPlayer2D.pitch_scale = 1.2 - (.06 * size)
	$AudioStreamPlayer2D.volume_db = -9 + (1.5 * size)
	
	#Gameplay randomization
	move_speed = Helpers.random.randi_range(20, 80) * pow(1.1,level-1)
	velocity = velocity.normalized() * move_speed
	damage = size #Multiplied by the round level in some way
	scale = Vector2(float(size) / 2, float(size) / 2)
	life = floor(Helpers.random.randi_range(1, size/2) * pow(1.1,level-1))
	
	
func die():
	# Prevent double triggering
	if !dead:
		dead = true
		$Sprite.visible = false
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		$Particles2D.emitting = true
		$AudioStreamPlayer2D.play()
		$DeathTimer.start()

func _process(delta):
	$Sprite.rotation_degrees += rotation_speed * delta

func _physics_process(delta):
	position += velocity * delta


func _on_Meteor_area_entered(area):
	if !area.is_in_group("obstacle"):
		if area.is_in_group("bullet"):
			life -= area.damage
			if life <= 0:
				die()
		else:
			die()


func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("emit_signal", "destroyed") # Possibly no if disappearing vs. destroyed matters
	call_deferred("free")


func _on_DeathTimer_timeout():
	call_deferred("emit_signal", "destroyed") # Possibly no if disappearing vs. destroyed matters
	call_deferred("free")
