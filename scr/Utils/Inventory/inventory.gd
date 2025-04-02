extends Node2D

var carried_weapon = null # Инвентарь с одним слотом

func pickup_weapon(new_weapon): # Функция подбора оружия
	
	if carried_weapon: # Проверка заполненности слота инвентаря
		drop_current_weapon()
		
	carried_weapon = new_weapon # Добавление оружия в пустой слот
	new_weapon.get_parent().remove_child(new_weapon) # Удаление оружия из игрового мира
	add_child(new_weapon) 
	new_weapon.position = Vector2.ZERO
	new_weapon.scale = Vector2(1.5, 1.5)
		
	if new_weapon.has_node("Area2D"): # Отключаем столкновения
		new_weapon.get_node("Area2D").monitoring = false
		
	print("Подобрано оружие: ", new_weapon.weapon_name)
		


func drop_current_weapon(): # Функция сброса текущего оружия
	if carried_weapon: # Проверяем заполненность слота инвентаря 
		remove_child(carried_weapon) # Удаляем оружие из инвентаря
		var game_scene = get_tree().current_scene # Определение игровой сцены
		game_scene.add_child(carried_weapon) # Добавление оружия обратно в игровую сцену
		var drop_position = get_parent().global_position # Определение позиции сброса
		carried_weapon.global_position = drop_position
		carried_weapon.scale = Vector2(0.3, 0.3)
		
		
		if carried_weapon.has_node("Area2D"): # Включение столкновения, чтобы оружие снова реагировало на пересечения
			carried_weapon.get_node("Area2D").monitoring = true
		
		print("Выброшено оружие: ", carried_weapon.weapon_name)
		carried_weapon = null
