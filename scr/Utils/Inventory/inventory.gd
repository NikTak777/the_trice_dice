extends Node2D

var carried_weapon = null # Инвентарь с одним слотом

var cooldown_multiplier := 1.0
var spread_disabled: bool = false
var spread_increased: bool = false

func pickup_weapon(new_weapon): # Функция подбора оружия
	
	if carried_weapon: # Проверка заполненности слота инвентаря
		if spread_disabled or spread_increased:
			carried_weapon.bullet_spread_degrees = carried_weapon.original_bullet_spread_degrees
			print("Возвращение разброса на ", carried_weapon.bullet_spread_degrees)
		drop_current_weapon()
		
	carried_weapon = new_weapon # Добавление оружия в пустой слот
	new_weapon.get_parent().remove_child(new_weapon) # Удаление оружия из игрового мира
	add_child(new_weapon) 
	new_weapon.position = Vector2.ZERO
	new_weapon.scale = Vector2(5.0, 5.0)
		
	if new_weapon.has_node("Area2D"): # Отключаем столкновения
		new_weapon.get_node("Area2D").monitoring = false
	
	if cooldown_multiplier != 1.0:
		new_weapon.cooldown_time *= cooldown_multiplier
	
	if spread_disabled:
		new_weapon.bullet_spread_degrees = 0.0
		print("Онулирование разброса на ", new_weapon.bullet_spread_degrees)
	if spread_increased:
		new_weapon.bullet_spread_degrees = new_weapon.original_bullet_spread_degrees * 1.5
		print("Увеличение разброса на ", new_weapon.bullet_spread_degrees)
	
	print("Подобрано оружие: ", new_weapon.weapon_name)
		

func drop_current_weapon(): # Функция сброса текущего оружия
	if carried_weapon: # Проверяем заполненность слота инвентаря 
		if carried_weapon.has_method("unequip"):
			carried_weapon.unequip()
		
		remove_child(carried_weapon) # Удаляем оружие из инвентаря
		var game_scene = get_tree().current_scene # Определение игровой сцены
		game_scene.add_child(carried_weapon) # Добавление оружия обратно в игровую сцену
		var drop_position = get_parent().global_position # Определение позиции сброса
		carried_weapon.global_position = drop_position
		carried_weapon.scale = Vector2(1.0, 1.0)
		
		if carried_weapon.has_node("Area2D"): # Включение столкновения, чтобы оружие снова реагировало на пересечения
			carried_weapon.get_node("Area2D").monitoring = true
		
		print("Выброшено оружие: ", carried_weapon.weapon_name)
		carried_weapon = null
