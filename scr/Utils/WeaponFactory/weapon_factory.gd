extends Node2D

# Конфигурация оружия: тип -> параметры
var weapon_data = {
	"Shotgun": {
		"weapon_name": "Shotgun",
		"cooldown_time": 1.0,
		"damage": 25,
		"sprite_target_height": 10.0,
		"weapon_texture": preload("res://scr/Assets/weapon_sprite/shotgun.png")
	},
	"Automat": {
		"weapon_name": "Automat",
		"cooldown_time": 0.2,
		"damage": 8,
		"sprite_target_height": 20.0,
		"weapon_texture": preload("res://scr/Assets/weapon_sprite/automat.png")
	}
}

var weapon_scene = preload("res://scr/Objects/Weapon/weapon.tscn")

func create_weapon(weapon_type: String) -> Node:
	if not weapon_data.has(weapon_type):
		push_error("Неизвестный тип оружия: " + weapon_type)
		return null
	var config = weapon_data[weapon_type]
	var weapon = weapon_scene.instantiate()
	
	# Устанавливаем параметры, которые экспортированы в базовом скрипте оружия
	weapon.weapon_name = config["weapon_name"]
	weapon.cooldown_time = config["cooldown_time"]
	weapon.damage = config["damage"]  # Если используется в скрипте пули или логике стрельбы
	weapon.sprite_target_height = config["sprite_target_height"]
	weapon.weapon_texture = config["weapon_texture"]
	
	return weapon
