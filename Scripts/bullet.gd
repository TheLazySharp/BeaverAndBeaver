class_name  Bullet
extends Area2D

var speed : float = 400
var max_range : = 400
@export var damages : int = 10
@onready var trail: CPUParticles2D = $VFX

var velocity : Vector2
var start_position : Vector2

@onready var gm_scene: Node = $"/root/World/game_manager"
var game_paused:=false

func _ready() -> void:
	gm_scene.game_paused.connect(_on_game_paused)

func fire(from_position: Vector2, direction: Vector2) -> void:
	#print(from_position)
	global_position = from_position
	start_position = from_position
	trail.global_position = global_position
	velocity = direction.normalized() * speed
	self.show()
	set_physics_process(true)
	trail.emitting = true
	rotation = 0


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
			reset_bullet()


func _on_area_hit(_area: Area2D) -> void:
	reset_bullet()


func _on_body_hit(body: Node2D) -> void:
	if "get_damages" in body and visible:
		body.get_damages(damages)
		reset_bullet()
	else:
		reset_bullet()

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause


func reset_bullet()-> void:
	visible = false
	set_physics_process(false)
