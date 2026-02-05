extends Node
class_name AbilityManager

var current_ability = null
var last_ability_key = null  # Ключ последней способности

var abilities = {
	#---------------------------------------------------------
	# Способность: увеличение текущего и максимального здоровья
	# Улучшает: увеличивает количество единиц здоровья на 20 процентов
	# Ухудшает: ничего
	#---------------------------------------------------------
	"mana_boost": {
		"description": "Уменьшает потребление маны",
		"activate": func(player):
			player.mana_manager.bonus = 1
			player.armor_bonus = 1.2,
		"deactivate": func(player):
			player.mana_manager.bonus = 0
			player.armor_bonus = 1.0,
	},
	#---------------------------------------------------------
	# Способность: увеличение урона оружия
	# Улучшает коэффициент увеличения урона на 20 процентов
	# Ухудшает прочность брони персонажа на 20 процентов
	#---------------------------------------------------------
	"damage_boost": {
		"description": "Увеличивает урон оружия",
		"activate": func(player):
			player.damage_bonus = 1.4 # Увеличиваем бонус урона у персонажа
			player.mana_manager.bonus = -2,
		"deactivate": func(player):
			player.damage_bonus = 1.0 # Сбрасываем бонус до исходного состояния
			player.mana_manager.bonus = 0,
	},
	#---------------------------------------------------------
	# Способность: увеличение скорость передвижения
	# Улучшает скорость передвижения персонажа с 100 до 115
	# Ухудшает урон оружия на 20 процентов
	#---------------------------------------------------------
	"speed_boost": {
		"description": "Увеличивает скорость передвижения",
		"activate": func(player):
			player.speed = 115
			player.damage_bonus = 0.8,
		"deactivate": func(player):
			player.speed = 100
			player.damage_bonus = 1.0,
	},
	#---------------------------------------------------------
	# Способность: увеличение скорострельности оружия
	# Улучшает скорострельность оружия на 20 процентов
	# Ухудшает максимальный угол отклонения пули (разброс оружия) с 10.0 до 15.0
	#---------------------------------------------------------
	"cooldown_time_boost": {
		"description": "Увеличивает скорострельность оружия",
		"activate": func(player):
			player.inventory.apply_cooldown_modifier_to_all_weapons(0.8)
			player.inventory.spread_increased = true
			player.inventory.cooldown_multiplier = 0.8
			player.inventory.apply_spread_modifiers_to_all_weapons(), 
		"deactivate": func(player):
			player.inventory.reset_cooldown_modifier_for_all_weapons(0.8)
			player.inventory.spread_increased = false
			player.inventory.cooldown_multiplier = 1.0
			player.inventory.reset_spread_modifiers_for_all_weapons(),
	},
	#---------------------------------------------------------
	# Способность: усиленная броня
	# Улучшает коэффициент усиления брони (умноженный на количество урона от врага) с 1.0 до 0.8
	# Ухудшает скорость перемещения персонажа с 100 до 90
	#---------------------------------------------------------
	"armor_boost": { # Название и описание предварительные 
		"description": "Увеличивает прочность брони",
		"activate": func(player):
			player.speed = 90
			player.armor_bonus = 0.6,
		"deactivate": func(player):
			player.speed = 100
			player.armor_bonus = 1.0,
	},
	#---------------------------------------------------------
	# Новая способность: снижение разброса оружия
	# Улучшает максимальный угол отклонения пули с 10.0 до 0.0
	# Ухудшает скорострельность оружия на 20 процентов
	#---------------------------------------------------------
	"no_spread": {
	"description": "Убирает разброс оружия",
	"activate": func(player):
		for weapon in player.inventory.weapons:
			if weapon:
				if weapon.weapon_type == "shotgun":
					weapon.bullet_spread_degrees /= 3.0
				else:
					weapon.bullet_spread_degrees = 0.0
				weapon.cooldown_time *= 1.2
		player.inventory.spread_disabled = true
		player.inventory.cooldown_multiplier = 1.2,
	"deactivate": func(player):
		for weapon in player.inventory.weapons:
			if weapon:
				weapon.bullet_spread_degrees = weapon.original_bullet_spread_degrees
				weapon.cooldown_time /= 1.2
		player.inventory.spread_disabled = false
		player.inventory.cooldown_multiplier = 1.0,
},
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
