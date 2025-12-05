extends Control

@onready var start: Button = $VBoxContainer/Start
@onready var quit: Button = $VBoxContainer/Quit

var first_scene = "uid://c6msxridefxxd"

func _ready() -> void:
	start.grab_focus()

func _on_start_pressed() -> void:
	SceneManager.load_level(first_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
