extends CharacterBody2D

var speed: float = 1000
@export var max_life: int = 50
@onready var target: Node2D = $"/root/World/Player"

@onready var gm_scene: Node = $"/root/World/game_manager"

@export var damages_text: PackedScene

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $path_Timer
@onready var damages_text_pos = get_node("MarkerDamages")


@onready var color_rect = get_node("ColorRect")
@onready var damage_timer: Timer = $DamageTimer
@onready var base_color: Color
@onready var current_life: int

var game_paused:=false

func _ready() -> void:
	randomize()
	navigation_agent.target_position = target.global_position
	base_color = color_rect.color
	current_life = max_life
	gm_scene.game_paused.connect(_on_game_paused)

func _physics_process(delta: float) -> void:
	if not game_paused:
		if not navigation_agent.is_target_reached():
			var nav_point_direction = to_local(navigation_agent.get_next_path_position()).normalized()
			velocity = nav_point_direction * speed * delta
			move_and_slide()

func _process(_delta: float) -> void:
	if current_life <=0:
		current_life = 0
		queue_free()


func _on_timer_timeout() -> void:
	if navigation_agent.target_position != target.global_position:
		navigation_agent.target_position = target.global_position
	timer.start()

func get_damages(damages: int) -> void:
	#print("enemy receives : ", damages)
	damage_timer.start()
	current_life -= damages
	color_rect.color= Color("ffffff")
	var text = damages_text.instantiate()
	var text_offsetX = RandomNumberGenerator.new().randf_range(-10,10)
	var text_offsetY = RandomNumberGenerator.new().randf_range(-10,0)
	text.this_label_text = str(damages)
	add_child(text)
	text.global_position = Vector2(damages_text_pos.global_position.x + text_offsetX, damages_text_pos.global_position.y + text_offsetY)

func spawn(spawn_position: Vector2):
	global_position = spawn_position

func _on_damage_timer_timeout() -> void:
	color_rect.color = base_color

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause
