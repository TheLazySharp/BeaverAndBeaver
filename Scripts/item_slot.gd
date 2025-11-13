extends Panel

@export var item: ItemData
@onready var icon: TextureRect = $Icon

signal dropped_item(item_dropped : ItemData)

func _ready() -> void:
	update_UI()

func _process(_delta: float) -> void:
	if item.quantity == 0:
		icon.modulate = Color(modulate,0.5)
	else: icon.modulate = Color(modulate,1)

func update_UI() -> void:
	if not item:
		icon.texture = null
		return
	icon.texture = item.icon
	tooltip_text = item.item_name

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null or item.quantity == 0:
		return
	
	var preview = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position -= Vector2(16,16) #half of the tile size
	preview.self_modulate = Color.TRANSPARENT
	c.modulate = Color(c.modulate,0.5)
	
	set_drag_preview(c)
	#icon.hide() transparent if quantity = 0
	emit_signal("dropped_item", item)
	return self


#=========== FOR MOVING ITEM INSIDE THE INVENTORY ==============================

#func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	#if item_quantity > 0:
		#return true
	#else: return false
	#
#func _drop_data(_at_position: Vector2, data: Variant) -> void:
	#var tmp = item 
	#item = data.item
	#data.item = tmp
	#icon.show()
	#data.show()
	#update_UI()
	#data.update_UI()
	#print("item dropped into inventory")
