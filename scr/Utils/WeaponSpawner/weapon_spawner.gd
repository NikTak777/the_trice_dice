extends Node2D

var weapon_scene = preload("res://scr/Objects/Weapon/weapon.tscn")  # Загружаем сцену оружия

# Спавн оружия во второй комнате
func spawn_weapon_in_room(room_number: int, map_generator):
	var weapon = weapon_scene.instantiate()  # Создаём оружие
	add_child(weapon)  # Добавляем оружие в текущую сцену

	# Получаем центр указанной комнаты
	var spawn_position = map_generator.get_room_center(room_number) * 16  # Умножаем на размер клетки

	# Устанавливаем позицию и масштаб оружия
	weapon.position = spawn_position
	weapon.scale = Vector2(0.3, 0.3)

	print("Оружие заспавнено в позиции: ", weapon.position)  # Лог для проверки
