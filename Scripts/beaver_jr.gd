extends CharacterBody2D

var max_life : int
var current_life : int

var speed:= 90
var boost:= 50
var back_to_pack_speed:= 0

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

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

#var is_packed:= true
var is_invincible:= false
var is_going_to_farm := false
var is_farming:= false
var is_taking_damages:= false
var is_being_healed:= false

@export var back_to_pack_threshold: float = 0.3
var is_coming_to_pack:= false

@onready var health_bar: ProgressBar = $HealthBar

@export var damages_text: PackedScene
@onready var damages_text_pos = get_node("MarkerDamages")

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
	if velocity.length()>0.1:
		animated_sprite.play("walk")
	else: animated_sprite.play("idle")
	
	
	if not is_going_to_farm or is_coming_to_pack:
		navigation_agent.target_position = beaver_sr.global_position + offset_pos
		var junior_direction = to_local(navigation_agent.get_next_path_position()).normalized()
		velocity = junior_direction * (speed + back_to_pack_speed)
		
	if not game_paused:
		if is_going_to_farm:
			#is_packed = false
			var junior_direction = to_local(navigation_agent.get_next_path_position()).normalized()
			velocity = junior_direction * speed
	if not game_paused:	
		move_and_slide()

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause

func spawn(spawn_position: Vector2):
	if not game_paused:
		global_position = spawn_position
		offset_pos = spawn_position - beaver_sr.position
		print(offset_pos)
		print("max life = ", max_life, "/ Current life = ", current_life)


func _on_radar_area_entered(ressource: Area2D) -> void:
	if ressource.is_in_group("ressources"):
		print("ressource detected")
		if not game_paused and not is_going_to_farm:
			is_going_to_farm = true
			is_invincible = true
			#is_packed = false
			navigation_agent.target_position = ressource.get_child(1).global_position #in the resource scene, FarmPoint is supposed to be second child
		if farmable_target == null:
			farmable_target = ressource.get_parent()


func _on_radar_area_exited(_area: Area2D) -> void:
	is_going_to_farm = false
	is_farming = false
	farming_timer.stop()
	print("farming ended")
	if not is_coming_to_pack:
		radar.set_deferred("disabled", true)
		radar.set_deferred("disabled", false)

func _on_target_reached() -> void:
	is_invincible = false
	if is_going_to_farm and not is_coming_to_pack:
		navigation_agent.target_position = position
		#print("ressource reached")
		farm()
	
	else: 
		#is_packed = true
		navigation_agent.target_position = beaver_sr.position + offset_pos

		if is_coming_to_pack:
			radar.set_deferred("disabled", false)
			is_coming_to_pack = false
		#print("back to daddy :)")
	

func farm() -> void:
	if not game_paused:
		if farmable_target != null and "take_damages" in farmable_target:
			farming_timer.start()
			is_farming = true
			if is_farming:
				farmable_target.take_damages(farming_power)
				#VFX farming

func _on_farming_timer_timeout() -> void:
	if farmable_target == null:
		return
	elif "take_damages" in farmable_target:
		farmable_target.take_damages(farming_power)

func back_to_pack() -> void:
	 #trouver le moyen de le repack correctement pour ne pas déclencher farm
	radar.set_deferred("disabled", true)
	is_coming_to_pack = true
	is_farming = false
	is_going_to_farm = false
	is_invincible = true
	back_to_pack_speed = boost
	#print("back to pack !!!")
	pass

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
