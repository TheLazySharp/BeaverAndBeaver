extends TileMapLayer

@onready var player: CharacterBody2D = $"/root/World/BeaverSr"

@onready var drop_item_to_world: Control = $/root/World/CanvasLayer/DropItemToWorld
@onready var main_layer : TileMapLayer = $"/root/World/Land_layers/Main"

#@export var item_manager: Node
var items: Array
var item: ItemData

@onready var selection_wheel: Control = $"/root/World/CanvasLayer/SelectionWheel"
var selection:int = -1


func _ready() -> void:
	items = InventoryManager.copy_items()
	selection_wheel.item_selected.connect(update_selection)
	item = items[selection]
	
func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_released("place_obstacles") and is_drop_tile and item.quantity > 0:
		#var tile_on_map = local_to_map(get_global_mouse_position())
	item = items[selection]
	if Input.is_action_just_released("drop_item") and item.quantity > 0 and selection >= 0:
		print("begin drop on item : ",selection)
		var tile_on_map = local_to_map(player.global_position + Vector2(0,-32))
		var tile_z_index = get_cell_tile_data(tile_on_map).get_z_index()
		if tile_z_index == 100:
			set_cell(tile_on_map,item.tileset_ID,item.tile_atlas_pos)
			main_layer.notify_runtime_tile_data_update()
			item.quantity -=1
			
			#is_drop_completed = true
			#emit_signal("drop_completed", is_drop_completed)
			#print("Step 2 - layer emits drop is completed : ",is_drop_completed)
		else : return
	
	#if Input.is_action_just_pressed("remove_obstacles"):
		#var tile_on_map = local_to_map(get_global_mouse_position())
		#set_cell(tile_on_map,8,Vector2i(-1,-1))
		#main_layer.notify_runtime_tile_data_update()
		#item.quantity +=1

#func update_drop_tile_status(drop_tile_OK) ->void:
	#is_drop_tile = drop_tile_OK
	#if not is_drop_tile:
		#is_drop_completed = false
		#print("Step 4.1 - layer received drop_tile_ok is : ",is_drop_tile)
		#print("Step 4.2 - layer received update is_drop_completed to  : ",is_drop_completed)
	
#func get_dropped_item_data(item_data) -> void:
	#item = item_data

func update_selection(item_selected) -> void:
	selection = item_selected
	print("tilemap received i : ",selection)
