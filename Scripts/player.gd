extends CharacterBody2D

@export var max_speed: float
@export var acceleration: float
@export var damping: float
@export var auto_shoot: bool

@onready var gun: Node2D = $Gun
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var game_paused:=false

var input_direction:= Vector2.ZERO

func _process(_delta: float) -> void:
	if not game_paused:
		process_inputs()
		process_animations()
	
func _physics_process(delta: float) -> void:
	if not game_paused:
		process_moves(delta)
		process_aim()
	
func process_inputs()-> void:
	input_direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if not auto_shoot and Input.is_action_pressed("shoot"):
		gun.shoot()
	
	if auto_shoot:
		gun.shoot()
	
func process_moves(delta : float) -> void:
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction.normalized() * max_speed,acceleration*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, damping*delta)
	
	move_and_slide()
	
func process_aim() -> void:
	if not auto_shoot:
		var mouse_world_position: = get_global_mouse_position()
		gun.look_at(mouse_world_position)
	else: gun.global_rotation_degrees = -90 

func process_animations() -> void:
	if velocity.length() > 0.5:
		animated_sprite.play("Walk")
	else:
		animated_sprite.play("Idle")

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause
