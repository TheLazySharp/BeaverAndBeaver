extends Area2D


func spawn(spawn_position):
	global_position = spawn_position



func _on_area_entered(_area: Area2D) -> void:
	queue_free()
