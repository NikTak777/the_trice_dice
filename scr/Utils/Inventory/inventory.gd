extends Node2D

var weapons: Array = []
var active_slot: int = 0

var cooldown_multiplier := 1.0
var spread_disabled: bool = false
var spread_increased: bool = false

func get_current_weapon():
	if weapons.size() == 0:
		return null
	if active_slot < 0 or active_slot >= weapons.size():
		return null
	return weapons[active_slot]
	
func _apply_modifiers_to_weapon(weapon):
	if weapon == null:
		return
	
	if cooldown_multiplier != 1.0:
		weapon.cooldown_time *= cooldown_multiplier
	
	if spread_disabled and weapon.weapon_type != "shotgun":
		weapon.bullet_spread_degrees = 0.0
	
	if spread_increased and weapon.weapon_type != "shotgun":
		weapon.bullet_spread_degrees = weapon.original_bullet_spread_degrees * 1.5
	
	if spread_disabled and weapon.weapon_type == "shotgun":
		weapon.bullet_spread_degrees /= 3.0
		
func _reset_spread_if_needed(weapon):
	if weapon == null:
		return
	if spread_disabled or spread_increased:
		weapon.bullet_spread_degrees = weapon.original_bullet_spread_degrees
		print("Возвращение разброса на ", weapon.bullet_spread_degrees)
		
func apply_modifiers_to_all_weapons():
	# Применяет текущие модификаторы ко всем оружиям в инвентаре
	for weapon in weapons:
		if weapon:
			_apply_modifiers_to_weapon(weapon)
			
func reset_modifiers_for_all_weapons():
	# Сбрасывает модификаторы для всех оружий
	for weapon in weapons:
		if weapon:
			_reset_spread_if_needed(weapon)
			# Сбрасываем cooldown_multiplier
			if cooldown_multiplier != 1.0:
				# Нужно вернуть cooldown к исходному значению
				# Для этого нужно знать исходное значение, но пока просто делим на множитель
				weapon.cooldown_time /= cooldown_multiplier

func apply_cooldown_modifier_to_all_weapons(multiplier: float):
	# Применяет множитель cooldown ко всем оружиям
	for weapon in weapons:
		if weapon:
			weapon.cooldown_time *= multiplier
			
func reset_cooldown_modifier_for_all_weapons(multiplier: float):
	# Сбрасывает множитель cooldown для всех оружий
	for weapon in weapons:
		if weapon:
			weapon.cooldown_time /= multiplier

func apply_spread_modifiers_to_all_weapons():
	# Применяет модификаторы разброса ко всем оружиям
	for weapon in weapons:
		if weapon:
			if spread_disabled and weapon.weapon_type != "shotgun":
				weapon.bullet_spread_degrees = 0.0
			elif spread_increased and weapon.weapon_type != "shotgun":
				weapon.bullet_spread_degrees = weapon.original_bullet_spread_degrees * 1.5
			elif spread_disabled and weapon.weapon_type == "shotgun":
				weapon.bullet_spread_degrees /= 3.0
				
func reset_spread_modifiers_for_all_weapons():
	# Сбрасывает модификаторы разброса для всех оружий
	for weapon in weapons:
		if weapon:
			weapon.bullet_spread_degrees = weapon.original_bullet_spread_degrees

func _update_weapon_visibility():
	for i in weapons.size():
		var weapon = weapons[i]
		if weapon:
			weapon.visible = (i == active_slot)

func pickup_weapon(new_weapon): # Функция подбора оружия
	
	# Если уже два оружия — выбрасываем текущее активное и кладём новое в его слот
	if weapons.size() == 2:
		var current_weapon = get_current_weapon()
		_reset_spread_if_needed(current_weapon)
		drop_current_weapon()
	
	# Определяем, в какой слот положить новое оружие
	var slot_index := weapons.size()
	if slot_index >= 2:
		slot_index = active_slot
		
	if slot_index >= weapons.size():
		weapons.append(new_weapon)
	else:
		weapons[slot_index] = new_weapon
		
	# Удаляем оружие из мира и добавляем в инвентарь
	if new_weapon.get_parent():
		new_weapon.get_parent().remove_child(new_weapon)
	add_child(new_weapon)
	new_weapon.position = Vector2.ZERO
	new_weapon.scale = Vector2(5.0, 5.0)
	
	# Делаем слот с этим оружием активным
	active_slot = slot_index
	_update_weapon_visibility()
		
	if new_weapon.has_node("Area2D"): # Отключаем столкновения
		new_weapon.get_node("Area2D").monitoring = false
	
	_apply_modifiers_to_weapon(new_weapon)
	
	print("Подобрано оружие: ", new_weapon.weapon_name)
	
	# Если теперь в инвентаре два оружия, показываем подсказку о переключении
	if weapons.size() == 2:
		_show_switch_weapon_hint()
		

func drop_current_weapon(): # Функция сброса текущего оружия
	drop_weapon(active_slot)


func drop_weapon(slot_index: int):
	if slot_index < 0 or slot_index >= weapons.size():
		return
	
	var weapon = weapons[slot_index]
	if weapon == null:
		return
	
	# Перед выбросом возвращаем разброс, если меняли
	_reset_spread_if_needed(weapon)
	
	if weapon.has_method("unequip"):
		weapon.unequip()
	
	remove_child(weapon) # Удаляем оружие из инвентаря
	var game_scene = get_tree().current_scene # Определение игровой сцены
	game_scene.add_child(weapon) # Добавление оружия обратно в игровую сцену
	var drop_position = get_parent().global_position # Определение позиции сброса
	weapon.global_position = drop_position
	weapon.scale = Vector2(1.0, 1.0)
	
	if weapon.has_node("Area2D"): # Включение столкновения
		weapon.get_node("Area2D").monitoring = true
	
	print("Выброшено оружие: ", weapon.weapon_name)
	
	weapons.remove_at(slot_index)
	
	if weapons.size() == 0:
		active_slot = 0
	else:
		if active_slot >= weapons.size():
			active_slot = weapons.size() - 1
	
	_update_weapon_visibility()

func switch_weapon():
	# Переключение между двумя слотами
	if weapons.size() < 2:
		return
	
	var current_weapon = get_current_weapon()
	if current_weapon and current_weapon.has_method("unequip"):
		current_weapon.unequip()
	
	active_slot = 1 - active_slot
	
	var new_weapon = get_current_weapon()
	_update_weapon_visibility()
	
	if new_weapon and new_weapon.has_method("equip"):
		new_weapon.equip()
	
func _show_switch_weapon_hint():
	# Получаем доступ к hint_manager через game сцену
	var game_scene = get_tree().current_scene
	if not game_scene:
		return
	
	# Ищем hint_manager среди дочерних узлов game
	for child in game_scene.get_children():
		if child is HintManager:
			child.show_hint("switch_weapon", 7.0)
			return
	
