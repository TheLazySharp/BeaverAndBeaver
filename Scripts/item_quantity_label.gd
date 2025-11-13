extends Label

@export var item : ItemData

func _process(_delta: float) -> void:
	set_text(str(item.quantity))
