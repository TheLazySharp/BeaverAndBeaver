extends Node2D

const BULLET = preload("uid://bjuws4ysoivbu")


@onready var timer: Timer = $FireRate
@onready var fire_point: Marker2D = $FirePoint

var can_shoot :=true

var max_bullet_count : int = 100
var bullet_pool : Array[Bullet]
var bullet_index : int = 0

func _ready() -> void:
	create_bullet_pool()
	

func _physics_process(_delta: float) -> void:
	global_position = get_parent().global_position


func shoot_from_pool()-> void :
	if not can_shoot: return
	can_shoot = false
	timer.start()
	var dir := Vector2.UP.normalized()
	var bullet = get_bullet_from_pool()
	bullet.fire(fire_point.global_position,dir)


func get_bullet_from_pool() -> Bullet:
	for i in bullet_pool:
		var bullet : Bullet = bullet_pool[bullet_index]
		if !bullet.visible:
			bullet_index = wrapi(bullet_index + 1, 0, max_bullet_count -1)
			return bullet
	return null


func _on_fire_rate_timeout() -> void:
	can_shoot = true

func create_bullet_pool():
	for i in max_bullet_count:
		var bullet : Bullet = BULLET.instantiate()
		bullet.reset_bullet()
		get_node("/root/World/Bullets").add_child(bullet)
		bullet_pool.append(bullet)
	print(bullet_pool.size(), " bullets have been pooled")
