extends RefCounted

func get_name() -> String: # имя команды, как её будут вызывать
	return "kill"
	
func get_arg_count() -> int: # количество аргументов команды
	return 1
	
func execute(args: Array, console) -> void: # сама логика
	
	var enemy_spawner = console.get_parent().enemy_spawner
	var room_number = str(args[0])
	if room_number == "all":
		for i in range(enemy_spawner.room_start, enemy_spawner.room_end + 1):
			if i == enemy_spawner.room_boss:
				continue
			enemy_spawner.kill_room_enemies(int(i))
	elif room_number == "boss":
		enemy_spawner.kill_room_enemies(int(enemy_spawner.room_boss))
	elif room_number == "help":
		console.print_to_console("Доступные аргументы команды 'kill':\nall")
		for i in range(enemy_spawner.room_start, enemy_spawner.room_end + 1):
			if i != enemy_spawner.room_boss:
				console.print_to_console(str(i))
				
	elif int(room_number) >= enemy_spawner.room_start and int(room_number) <= enemy_spawner.room_end:
		if int(room_number) == enemy_spawner.room_boss:
			console.print_to_console("Ошибка: запрещено отчищать комнату босса")
		else:
			enemy_spawner.kill_room_enemies(int(room_number))
	else:
		console.print_to_console("Ошибка: некорректный аргумент функции 'kill'")
