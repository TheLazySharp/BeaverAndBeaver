extends Marker2D

@onready var timer: Timer = $Timer
@export var ennemy_scene : PackedScene

var game_paused:=false

func _ready() -> void:
	randomize()

func create_ennemy(starting_position: Vector2) -> void:
	var ennemy := ennemy_scene.instantiate()
	ennemy.spawn(starting_position)
	add_child(ennemy)
	print("ennemy created")

func _on_timer_timeout() -> void:
	if not game_paused:
		var offsetX = RandomNumberGenerator.new().randf_range(-250,250)
		create_ennemy(Vector2(offsetX,0))

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause
