extends Node

var xp_levels: Array
var current_level: int
var current_xp: int
var current_level_target_xp: int
var total_levels:int = 50

var animation:= false

#@onready var xp_bar: ProgressBar = $"/root/World/PlayerManager/XPManager/CanvasLayer/xp_bar"
#@onready var label: Label = $"/root/World/PlayerManager/XPManager/CanvasLayer/xp_bar/Label"
#@onready var animation_player: AnimationPlayer = $"/root/World/PlayerManager/XPManager/CanvasLayer/xp_bar/AnimationPlayer"

signal update_xp(current_xp: int)
signal update_max_xp_target(target_xp: int)
signal animation_play(animation_ok : bool)
signal update_level(current_level: int)

func _ready() -> void:
	for i in (total_levels+1):
		@warning_ignore("integer_division")
		xp_levels.append(round( (4 * (i**2) ) * 0.2 )+3)
	current_level = 1
	#label.text = "Lvl " + str(current_level)
	current_level_target_xp = xp_levels[current_level]
	current_xp = 0
	#xp_bar.value = current_xp
	#xp_bar.max_value = current_level_target_xp
	#print("Current Level = ",current_level," / current target xp = ",current_level_target_xp)
	emit_signal("update_xp", current_xp)
	emit_signal("update_max_xp_target", current_level_target_xp)
	emit_signal("update_level",current_level)
	
	
func _process(_delta: float) -> void:
	if current_xp >= current_level_target_xp:
		level_up()

func get_xp(xp) -> void:
	current_xp += xp
	emit_signal("update_xp", current_xp)
	
	#xp_bar.value = current_xp
	#print("Player xp gets + ",xp," / total xp = ",current_xp)

func level_up() -> void:
	#print("level up")
	current_level += 1
	current_level_target_xp = xp_levels[current_level]
	current_xp -= xp_levels[current_level-1]
	#label.text = "Lvl " + str(current_level)
	emit_signal("update_level",current_level)
	
	#animation_player.play("level_up_anim")
	animation = true
	emit_signal("animation_play", animation)
	await get_tree().create_timer(0.8).timeout
	emit_signal("update_xp", current_xp)
	emit_signal("update_max_xp_target", current_level_target_xp)
	#xp_bar.max_value = current_level_target_xp
	#xp_bar.value = current_xp
	#print("Current Level = ",current_level," / current target xp = ",current_level_target_xp)
