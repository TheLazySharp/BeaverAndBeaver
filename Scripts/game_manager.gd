extends Node

var game_on_pause:= false
signal game_paused(game_on_pause: bool)

func _process(_delta: float) -> void:
	process_inputs()
	
	
func process_inputs()-> void:
	if Input.is_action_just_released("pause"):
		pause_status()

func pause_status()-> void:
	if not game_on_pause:
		game_on_pause = true
		print("game paused by player")
		emit_signal("game_paused", game_on_pause)
	else:
		game_on_pause = false
		emit_signal("game_paused", game_on_pause)
		print("game unpaused by player")
