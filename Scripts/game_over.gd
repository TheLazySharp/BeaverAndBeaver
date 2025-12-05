extends Control

@onready var restart: Button = $VBoxContainer/Restart
@onready var menu: Button = $VBoxContainer/Menu
@onready var quit: Button = $VBoxContainer/Quit


var first_scene = "uid://c6msxridefxxd"
var menu_scene = "uid://gmjjc1vmgcds"


func _ready() -> void:
	restart.grab_focus()

func _on_restart_pressed() -> void:
	SceneManager.load_level(first_scene)


func _on_menu_pressed() -> void:
		SceneManager.load_level(menu_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
