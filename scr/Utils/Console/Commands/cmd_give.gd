extends RefCounted

func get_name() -> String: # имя команды, как её будут вызывать
	return "give"
	
func get_arg_count() -> int: # количество аргументов команды
	return 1
	
func execute(args: Array, console) -> void: # сама логика
	var weapon_name = str(args[0]).strip_edges()
	var player = console.get_tree().get_nodes_in_group("player")[0]
	var weapon_factory_scene = preload("res://scr/Utils/WeaponFactory/WeaponFactory.tscn")
	var weapon_factory = weapon_factory_scene.instantiate()
	console.add_child(weapon_factory)
		
	if weapon_name == "help":
		var weapon_list = weapon_factory.weapon_data.keys()
		console.print_to_console("Доступное оружие:")
		for w in weapon_list:
			console.print_to_console(" - " + w)
		return
			
	if not weapon_factory.weapon_data.has(weapon_name):
		console.print_to_console("Ошибка: оружие '" + weapon_name + "' не найдено")
		weapon_factory.queue_free()
		return
		
	var new_weapon = weapon_factory.create_weapon(weapon_name)
	console.add_child(new_weapon)
	player.inventory.pickup_weapon(new_weapon)
	new_weapon.equip()
	player.nearby_weapon = null
		
	console.print_to_console("Игроку выдано оружие " + weapon_name)
