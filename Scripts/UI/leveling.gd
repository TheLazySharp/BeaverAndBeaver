extends Control

var current_level: int

signal game_paused(game_on_pause: bool)
var game_is_paused: = false

@onready var skip: Button = $VBoxContainer/Skip
@onready var confirm: Button = $VBoxContainer/Confirm


func _ready() -> void:
	XPManager.update_level.connect(level_up)



func _process(_delta: float) -> void:
	pass


func level_up(new_current_level):
	current_level = new_current_level
	game_is_paused = true
	emit_signal("game_paused", game_is_paused)
	get_focus()
	show()



func _on_skip_pressed() -> void:
	game_is_paused = false
	emit_signal("game_paused", game_is_paused)
	hide()


func _on_confirm_pressed() -> void:
	#do somethign
	game_is_paused = false
	emit_signal("game_paused", game_is_paused)
	hide()

func get_focus():
	skip.grab_focus()
