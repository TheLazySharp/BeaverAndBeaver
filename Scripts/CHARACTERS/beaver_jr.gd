extends CharacterBody2D

var max_life : int
var current_life : int

var speed:= 100
var acceleration := 250
var boost:= 4
var back_to_pack_speed:= 4

var farmable_target: Node2D
var farming_power:= 10

@onready var farming_timer: Timer = $FarmingTimer
@onready var taking_damages: Timer = $TakingDamages

@onready var radar: CollisionShape2D = $Radar/DetectionRange
@onready var animated_sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer

@onready var beaver_sr: CharacterBody2D = $/root/World/BeaverSr
var offset_pos: Vector2

@onready var gm_scene: Node = $"/root/World/game_manager"
var game_paused:=false

@onready var wood_vfx: GPUParticles2D = $Visuals/WoodVFX

var is_invincible:= false
var is_going_to_farm := false
var is_farming:= false
var is_taking_damages:= false
var is_being_healed:= false
var is_idle:= true
@export var back_to_pack_threshold: float = 0.3
var is_coming_to_pack:= false

@onready var health_bar: ProgressBar = $HealthBar

@export var damages_text: PackedScene
@onready var damages_text_pos = get_node("MarkerDamages")

var target_pos: Vector2

func _ready() -> void:
	max_life = 500
	current_life = 300
	gm_scene.game_paused.connect(_on_game_paused)
	farmable_target = null
	health_bar.min_value = 0
	health_bar.max_value = max_life
	health_bar.value = current_life


func _process(_delta: float) -> void:
	if Input.is_action_just_released("go_pack") or current_life < max_life * back_to_pack_threshold:
		back_to_pack()

		
func _physics_process(_delta: float) -> void:
	if abs(global_position - target_pos).length() < 3:
		is_idle = true
	else: 
		is_idle = false
		
	if !is_idle and !is_farming:
		animated_sprite.play("walk")
	if is_idle or is_farming : 
		animated_sprite.play("idle")
	
	if not is_going_to_farm:
		target_pos = beaver_sr.global_position + offset_pos
		if abs(global_position - target_pos).length() < 3:
			radar.set_deferred("disabled", false)
			


	if !game_paused:
		if !is_farming and !is_idle:
			var direction = position.direction_to(target_pos)
			velocity = velocity.move_toward(direction * speed, acceleration)
			move_and_slide()

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause

func spawn(spawn_position: Vector2):
	if not game_paused:
		global_position = spawn_position
		offset_pos = spawn_position - beaver_sr.position
		print(offset_pos)
		print("max life = ", max_life, "/ Current life = ", current_life)


func _on_radar_area_entered(resource: Area2D) -> void:
	if resource.get_collision_layer_value(13):
		print("resource detected")
		if !is_going_to_farm:
			is_going_to_farm = true
			is_invincible = true
			target_pos = resource.get_child(1).global_position

		if farmable_target == null:
			farmable_target = resource.get_parent()


func _on_radar_area_exited(_area: Area2D) -> void:
	is_going_to_farm = false
	is_farming = false
	farming_timer.stop()
	wood_vfx.emitting = false
	wood_vfx.hide()
	print("farming ended")
	if not is_coming_to_pack:
		radar.set_deferred("disabled", true)
		radar.set_deferred("disabled", false)


	

func farm() -> void:
	if not game_paused:
		if farmable_target != null and "take_damages" in farmable_target:
			#animated_sprite.play("idle")
			print("farming")
			farming_timer.start()
			wood_vfx.restart()
			wood_vfx.show()
			is_farming = true
			if is_farming:
				farmable_target.take_damages(farming_power)

func _on_farming_timer_timeout() -> void:
	if farmable_target == null:
		is_farming = false
		return
	elif "take_damages" in farmable_target:
		farmable_target.take_damages(farming_power)

func back_to_pack() -> void:
	radar.set_deferred("disabled", true)
	is_coming_to_pack = true
	is_farming = false
	is_going_to_farm = false
	is_invincible = true
	back_to_pack_speed = boost
	#print("back to pack !!!")

func process_healing(healing: int) -> void:
	if not game_paused:
		if current_life >= max_life: 
			current_life = max_life
			health_bar.value = current_life
			#print("junior is fully healed")
			
			return
		if current_life < max_life:
			is_being_healed = true
			current_life += healing
			health_bar.value = current_life
			#print("junior is healing : ",current_life)
			is_being_healed = false

func take_damages(damages: int) -> void:
	if not game_paused:
		if not is_invincible:
			is_taking_damages = true
			current_life -= damages
			health_bar.value = current_life
			display_damages(damages)
			print(str(current_life))
			self.animation_player.play("beaverJR_animations/flash")
			taking_damages.start()
			
			if current_life <=0:
				current_life = 0
				health_bar. value = current_life
				play_death()
				return
				
			if is_taking_damages:return

func play_death() -> void:
	is_taking_damages = false
	self.animation_player.stop()
	#print("Beaver Jr is dead god DAM IT")

func _on_taking_damages_timeout() -> void:
	is_taking_damages = false
	animation_player.stop()

	
func display_damages(damages)-> void:
	if not game_paused:
		var text = damages_text.instantiate()
		var text_offsetX = RandomNumberGenerator.new().randf_range(-10,10)
		var text_offsetY = RandomNumberGenerator.new().randf_range(-10,0)
		text.this_label_text = "- " +str(damages)
		add_child(text)
		text.global_position = Vector2(damages_text_pos.global_position.x + text_offsetX, damages_text_pos.global_position.y + text_offsetY)


func _on_collect_zone_entered(area: Area2D) -> void:
	if area.is_in_group("collectables"):
		XPManager.get_xp(1)
		
	if area.get_collision_layer_value(12) and is_going_to_farm:
		print("junior in farming area")
		farm()
