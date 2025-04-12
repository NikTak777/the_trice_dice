extends Node
class_name AbilityManager

var current_ability = null
var last_ability_key = null  # Ключ последней способности

var abilities = {
	"hp_boost": {
		"description": "Увеличивает текущее и максимальное HP",
		"activate": func(player):
			player.max_hp *= 1.2
			player.current_hp *= 1.2
			player.hp_bar.set_hp(player.current_hp) # Обновляем прогресс бар через метод set_hp()
			player.hp_bar.bar.max_value = player.max_hp, # Обновляем максимальное значение прогресс бара
		"deactivate": func(player):
			# Возвращаем бонус HP назад
			player.max_hp /= 1.2
			player.hp_bar.bar.max_value = player.max_hp,
	},
	"damage_boost": {
		"description": "Увеличивает урон оружия",
		"activate": func(player):
			player.damage_bonus = 1.2, # Увеличиваем бонус урона у персонажа
		"deactivate": func(player):
			player.damage_bonus = 1.0, # Сбрасываем бонус до исходного состояния
	},
	"speed_boost": {
		"description": "Увеличивает скорость передвижения",
		"activate": func(player):
			player.speed = 115,
		"deactivate": func(player):
			player.speed = 100,
	}
}

func change_ability(player):
	# Если есть активная способность, деактивируем её
	if current_ability:
		current_ability["deactivate"].call(player)
	
	# Получаем список ключей способностей
	var keys = abilities.keys()
	
	# Если вариантов больше одного и у нас есть последняя способность, исключаем её
	if last_ability_key != null and keys.size() > 1:
		keys.erase(last_ability_key)
	
	# Выбираем случайную способность из оставшихся вариантов
	var random_key = keys[randi() % keys.size()]
	current_ability = abilities[random_key]
	
	# Активируем выбранную способность
	current_ability["activate"].call(player)
	
	# Сохраняем ключ последней способности
	last_ability_key = random_key
	
	# Возвращаем описание для вывода в консоль или на экран
	return current_ability["description"]
