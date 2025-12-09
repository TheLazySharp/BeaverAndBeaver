extends Node

const AXE = preload("uid://m78cavmqijx3")
const BOW = preload("uid://bsa4806plmw2s")
const ARROW = preload("uid://b8nw2s85q3f0a")



@export var weapons : Array[WeaponData]



func _ready() -> void:
	weapons.append(AXE)
	weapons.append(BOW)
	weapons.append(ARROW)




func equip_weapon() -> void:
	pass

func unequip_weapon() -> void:
	pass

func level_up() -> void:
	pass
