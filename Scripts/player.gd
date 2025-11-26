extends CharacterBody2D

var max_speed: float = 250
var acceleration: float = 250
var damping: float = 250
var healing_power:= 10
var max_life: int = 1000
var current_life: int

@export var auto_shoot: bool
@export var semi_auto_shoot: bool


@onready var healing_timer: Timer = $HealingTimer

@onready var gun: Node2D = $Gun
@onready var animated_sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var healing_world_area: Node2D = $HealingZone/HealingWorldArea
@onready var collect_zone: CollisionShape2D = $CollectZone/CollectZone


@export var damages_text: PackedScene
@onready var damages_text_pos = get_node("MarkerDamages")
@onready var taking_damages: Timer = $TakingDamages

var injureds: Array

var injured: Node = null

var is_taking_damages:=false
var game_paused:=false
var input_direction:= Vector2.ZERO

func _ready() -> void:
	current_life = max_life
	healing_world_area.visible = false
	semi_auto_shoot = true
	auto_shoot = false

func _process(_delta: float) -> void:
	if auto_shoot: semi_auto_shoot = false
	if semi_auto_shoot: auto_shoot = false
	
	if not game_paused:
		process_inputs()
		process_animations()

func _physics_process(delta: float) -> void:
	if not game_paused:
		process_moves(delta)
		process_aim()
	
func process_inputs()-> void:
	input_direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if semi_auto_shoot and Input.is_action_pressed("shoot"):
		gun.shoot()
	
	if auto_shoot:
		gun.shoot()
	
func process_moves(_delta : float) -> void:
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction.normalized() * max_speed,acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, damping)
	
	move_and_slide()
	
func process_aim() -> void:
	if not auto_shoot:
		var mouse_world_position: = get_global_mouse_position()
		gun.look_at(mouse_world_position)
	else: gun.global_rotation_degrees = -90 

func process_animations() -> void:
	if velocity.length() > 0.5:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause

func take_damages(damages: int) -> void:
	if not game_paused:
		is_taking_damages = true
		current_life -= damages
		display_damages(damages)
		print(str(current_life))
		animation_player.play("beaver_animations/flash")
		taking_damages.start()
		
		if current_life <=0:
			current_life = 0
			play_death()
			return
			
		if is_taking_damages:return

func play_death() -> void:
	is_taking_damages = false
	animation_player.stop()
	#print("Mr beaver is dead god DAM IT")


func _on_taking_damages_timeout() -> void:
	is_taking_damages = false
	animation_player.stop()
	
func display_damages(damages)-> void:
	var text = damages_text.instantiate()
	var text_offsetX = RandomNumberGenerator.new().randf_range(-10,10)
	var text_offsetY = RandomNumberGenerator.new().randf_range(-10,0)
	text.this_label_text = "- " +str(damages)
	add_child(text)
	text.global_position = Vector2(damages_text_pos.global_position.x + text_offsetX, damages_text_pos.global_position.y + text_offsetY)



func _on_healing_zone_entered(area: Area2D) -> void:
	if not area.is_in_group("junior"): return
	healing_world_area.visible = true
	injured = area.get_parent()
	injureds.append(injured)
	for i in injureds.size():
		var healed = injureds[i]
		#print(healed)
		if "process_healing" in healed:
			healed.process_healing(healing_power)
		healing_timer.start()


func _on_healing_zone_exited(area: Area2D) -> void:
	if not area.is_in_group("junior"): return
	healing_world_area.visible = false
	injureds.erase(injured)
	injured = null
	healing_timer.stop()


func _on_healing_timer_timeout() -> void:
	if injured == null: return
	for i in injureds.size():
		var healed = injureds[i]
		#print(healed)
		if "process_healing" in healed:
			healed.process_healing(healing_power)


func _on_collect_zone_entered(area: Area2D) -> void:
	if area.is_in_group("collectables"):
		player_xp_manager.get_xp(1)
