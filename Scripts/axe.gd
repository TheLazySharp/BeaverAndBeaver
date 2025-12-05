extends Area2D

var speed_rotation:= 15
var speed:= 5
var d := 0.0
var radius := 100
var offset_position: Vector2
var dmg := 20
var dmg_on_ressources := 1

@onready var gm_scene: Node = $"/root/World/game_manager"
var game_paused:=false

func _ready() -> void:
	gm_scene.game_paused.connect(_on_game_paused)


func _physics_process(delta: float) -> void:
	offset_position = get_parent().global_position
	rotation += speed_rotation * delta
	d += delta
	if !game_paused:
		global_position = Vector2(sin(d * speed) * radius, cos(d * speed) * radius) + offset_position


func _on_body_entered(body: Node2D) -> void:
		if body.is_in_group("ennemies") and "get_damages" in body:
			body.get_damages(dmg)
		else : return

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ressources") and "take_damages" in area.get_parent():
		print("ressources hit")
		area.get_parent().take_damages(dmg_on_ressources)
	else : return
