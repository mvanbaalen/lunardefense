extends Area2D


export (int) var speed = 800
var velocity = Vector2()
var marked = false
var speed_level = 1
var damage = 1
var power_level = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	var linear_speed = clamp(speed + (speed/2 * speed_level), 1, 3000)
	velocity = velocity.normalized() * linear_speed
	damage = damage * power_level


func _physics_process(delta):
	position += velocity * delta

func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("queue_free")

func _on_Bullet_area_entered(area):
	if !area.is_in_group("bullet"):
		call_deferred("queue_free")
