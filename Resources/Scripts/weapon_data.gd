extends Resource

class_name WeaponData

@export var weapon_name : String
@export var weapon_icon: Texture2D
@export var dmg:= 5
@export var dmg_on_resources := 1
@export var atk_range : float
@export var radius := 100
@export var speed : float
@export var speed_rotation:= 15
@export var wood_cost: int
@export var stone_cost: int
@export var fire_rate: float
@export var nb_ammo: int

var level: int = 0
var crafted:=false
 
