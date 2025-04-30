extends Node2D

var weapon_scene = preload("res://scr/Objects/Weapon/weapon.tscn")  # Загружаем сцену оружия

var factory_scene = preload("res://scr/Utils/WeaponFactory/WeaponFactory.tscn")

# Спавн оружия во второй комнате с заданным типом
func spawn_weapon_in_room(room_number: int, map_generator, weapon_type: String) -> Node:
	var weapon_factory = factory_scene.instantiate()
	var weapon = weapon_factory.create_weapon(weapon_type)
	add_child(weapon)
	
	var spawn_position = map_generator.get_room_center(room_number) * 16
	
	if room_number == 1:
		spawn_position.y += 25
		print(spawn_position.y)
	
	weapon.position = spawn_position
	
	
	print("Оружие", weapon.weapon_name, "заспавнено в позиции:", weapon.position)
	return weapon
	
