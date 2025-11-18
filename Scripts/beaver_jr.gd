extends CharacterBody2D

var max_life := 500
var current_life : int
var healing:= 5
var speed:= 90

var farmable_target: Node2D
var farming_power:= 10

@onready var farming_timer: Timer = $FarmingTimer

@onready var radar: CollisionShape2D = $Radar/DetectionRange

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var beaver_sr: CharacterBody2D = $/root/World/BeaverSr
var offset_pos: Vector2

@onready var gm_scene: Node = $"/root/World/game_manager"
var game_paused:=false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
#var pack_position : Vector2

var is_packed:= true
var is_invincible:= false

var is_going_to_farm := false
var is_farming:= false

var is_coming_to_pack:= false

func _ready() -> void:
	current_life = max_life
	gm_scene.game_paused.connect(_on_game_paused)
	farmable_target = null
	#pack_position = beaver_sr.global_position + offset_pos
	
func _process(_delta: float) -> void:
	if is_packed and not game_paused:
		process_healing()
	back_to_pack()
	

func _physics_process(_delta: float) -> void:
	if velocity.length()>0.1:
		animated_sprite.play("walk")
	else: animated_sprite.play("idle")
	
	if is_packed or not is_going_to_farm or is_coming_to_pack:
		navigation_agent.target_position = beaver_sr.global_position + offset_pos
		var junior_direction = to_local(navigation_agent.get_next_path_position()).normalized()
		velocity = junior_direction * speed
		
	if not game_paused:
		if is_going_to_farm:
			is_packed = false
			var junior_direction = to_local(navigation_agent.get_next_path_position()).normalized()
			velocity = junior_direction * speed
		
	move_and_slide()
	
#fonction pour qu'il revienne en pack très vite

func _on_game_paused(game_on_pause) -> void:
	game_paused = game_on_pause

func spawn(spawn_position: Vector2):
	global_position = spawn_position
	offset_pos = spawn_position - beaver_sr.position
	print(offset_pos)

func process_healing()->void:
	if current_life < max_life:
		current_life += healing
		#VFX
	if current_life >= max_life:
		current_life = max_life


func _on_radar_area_entered(ressource: Area2D) -> void:
	print("ressource detected")
	if not game_paused and not is_going_to_farm:
		is_going_to_farm = true
		is_invincible = true
		is_packed = false
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
	if not is_packed and is_going_to_farm and not is_coming_to_pack:
		navigation_agent.target_position = position
		#print("ressource reached")
		farm()
	
	else: 
		is_packed = true
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
		
func take_damages(damages: int) -> void:
	if not is_invincible:
		current_life -= damages
		

func back_to_pack() -> void:
	if Input.is_action_just_released("go_pack"): #trouver le moyen de le repack correctement pour ne pas déclencher farm
		radar.set_deferred("disabled", true)
		is_coming_to_pack = true
		is_farming = false
		is_going_to_farm = false
		is_invincible = true
		print("back to pack !!!")
		pass
