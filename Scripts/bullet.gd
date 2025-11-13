extends Area2D

@export var speed : float
@export var max_range : float
@export var damages : int = 2

var velocity : Vector2
var start_position : Vector2

func fire(from_position: Vector2, direction: Vector2) -> void:
	global_position = from_position
	start_position = from_position
	velocity = direction.normalized() * speed
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	var next_position = global_position + velocity * delta
	global_position = next_position
	
	if start_position.distance_to(global_position) > max_range:
		queue_free()


func _on_area_hit(_area: Area2D) -> void:
	queue_free()


func _on_body_hit(body: Node2D) -> void:
	##vérifier dabord si la fonction existe dans le body
	if "get_damages" in body:
		body.get_damages(damages)
		queue_free()
	else:
		queue_free()
