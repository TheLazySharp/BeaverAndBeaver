extends Node2D

@export var bullet_scene: PackedScene

@onready var timer: Timer = $FireRate
@onready var fire_point: Marker2D = $FirePoint

var can_shoot :=true

func shoot() -> void:
	if not can_shoot: return
	can_shoot = false
	timer.start()
	var bullet :=bullet_scene.instantiate()
	var dir := Vector2.UP.normalized()
	bullet.fire(fire_point.global_position,dir)
	
	get_tree().current_scene.add_child(bullet)

func _on_timer_timeout() -> void:
	can_shoot = true
