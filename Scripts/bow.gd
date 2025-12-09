extends Node2D

const BULLET = preload("uid://bjuws4ysoivbu")

@export var bow_data: WeaponData


@onready var timer: Timer = $FireRate
@onready var fire_point: Marker2D = $FirePoint

var nb_ammo: int

var can_shoot :=true

var max_bullet_count : int = 100
var bullet_pool : Array[Bullet]
var bullet_index : int = 0

var bullet_spread_angle: float = 10

func _ready() -> void:
	timer.wait_time = bow_data.fire_rate
	nb_ammo = bow_data.nb_ammo
	create_bullet_pool()
	

func _physics_process(_delta: float) -> void:
	global_position = get_parent().global_position


func shoot_from_pool()-> void :
	if !can_shoot: return
	can_shoot = false
	timer.start()
	var start_angle = -((nb_ammo - 1) * bullet_spread_angle) * .5
	for i in nb_ammo:
		var angle : float = deg_to_rad(start_angle + i * bullet_spread_angle)
		var bullet = get_bullet_from_pool()
		var dir = Vector2.UP.rotated(angle)
		bullet.fire(fire_point.global_position,dir,angle)



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
