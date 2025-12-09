class_name  Bullet
extends Area2D

@export var arrow_data: WeaponData

var speed
var max_range
var damages
@onready var trail: CPUParticles2D = $VFX

var velocity : Vector2
var start_position : Vector2

@onready var gm_scene: Node = $"/root/World/game_manager"
var game_paused:= false

var is_active:= false

func _ready() -> void:
	gm_scene.game_paused.connect(_on_game_paused)
	speed = arrow_data.speed
	max_range = arrow_data.atk_range
	damages = arrow_data.dmg

func fire(from_position: Vector2, direction: Vector2, angle: float) -> void:
	#print(from_position)
	global_position = from_position
	start_position = from_position
	trail.global_position = global_position
	velocity = direction.normalized() * speed
	self.show()
	is_active = true
	set_physics_process(true)
	trail.restart()
	rotation = angle


func _physics_process(delta: float) -> void:
	if not game_paused:
		var next_position = global_position + velocity * delta
		global_position = next_position
		if self.global_position.y <= (self.start_position.y - 50) :
			trail.global_position = global_position
			#print("y ; ",global_position.y, " / start y : ", str(start_position.y - 50))
			trail.show()
		
	
	if start_position.distance_to(global_position) > max_range:
		if not game_paused:
			trail.emit_signal("finished")
			reset_bullet()


func _on_area_hit(_area: Area2D) -> void:
	pass
	#trail.emit_signal("finished")
	#hitbox.set_deferred("disabled", true)
	#reset_bullet()


func _on_body_hit(body: Node2D) -> void:
	if "get_damages" in body and body.is_in_group("ennemies") and is_active:
		body.get_damages(damages)
		trail.emit_signal("finished")
		reset_bullet()
	else:
		trail.emit_signal("finished")
		reset_bullet()

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause


func reset_bullet()-> void:
	visible = false
	is_active = false
	set_physics_process(false)
	global_position = Vector2(-10,-10)
