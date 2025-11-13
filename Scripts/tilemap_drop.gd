extends TileMapLayer

var is_drop_completed := false
var is_drop_tile :=false

signal drop_completed(is_drop_completed: bool)

@onready var drop_item_to_world: Control = $/root/World/CanvasLayer/DropItemToWorld

@onready var item_slot: Panel = $/root/World/CanvasLayer/Inventory/MarginContainer/GridContainer/ItemSlot
@onready var item_slot2: Panel = $/root/World/CanvasLayer/Inventory/MarginContainer/GridContainer/ItemSlot2

var item: ItemData

func _ready() -> void:
	drop_item_to_world.drop_tile.connect(update_drop_tile_status)
	item_slot.dropped_item.connect(get_dropped_item_data)
	item_slot2.dropped_item.connect(get_dropped_item_data)
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("place_obstacles") and is_drop_tile:
		var tile_on_map = local_to_map(get_global_mouse_position())
		var tile_z_index = get_cell_tile_data(tile_on_map).get_z_index()
		if tile_z_index == 100:
			set_cell(tile_on_map,item.tileset_ID,item.tile_atlas_pos)

			is_drop_completed = true
			emit_signal("drop_completed", is_drop_completed)
			#print("Step 2 - layer emits drop is completed : ",is_drop_completed)
		else : return
	
	if Input.is_action_just_pressed("remove_obstacles"):
		var tile_on_map = local_to_map(get_global_mouse_position())
		set_cell(tile_on_map,8,Vector2i(-1,-1))

func update_drop_tile_status(drop_tile_OK) ->void:
	is_drop_tile = drop_tile_OK
	if not is_drop_tile:
		is_drop_completed = false
		#print("Step 4.1 - layer received drop_tile_ok is : ",is_drop_tile)
		#print("Step 4.2 - layer received update is_drop_completed to  : ",is_drop_completed)
	
func get_dropped_item_data(item_data) -> void:
	item = item_data
	
