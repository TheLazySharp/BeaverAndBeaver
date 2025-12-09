extends Marker2D

@onready var timer: Timer = $Timer
@export var ennemy_scene : PackedScene

var game_paused:=false

@export var auto_spawn:= true

func _ready() -> void:
	randomize()
	
func create_ennemy(starting_position: Vector2) -> void:
	var ennemy := ennemy_scene.instantiate()
	ennemy.spawn(starting_position)
	get_node("/root/World/Ennemies").add_child(ennemy)
	#print("ennemy created at : ", starting_position)

func _on_timer_timeout() -> void:
	if not game_paused and auto_spawn:
		var offsetX = RandomNumberGenerator.new().randf_range(-200,200)
		create_ennemy(Vector2(global_position.x + offsetX,global_position.y))

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause
