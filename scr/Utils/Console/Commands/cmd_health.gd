extends RefCounted

func get_name() -> String: # имя команды, как её будут вызывать
	return "health"
	
func get_arg_count() -> int: # количество аргументов команды
	return 1
	
func execute(args: Array, console) -> void: # сама логика
	var hp = int(args[0])
	var player = console.get_tree().get_nodes_in_group("player")[0]
	var max_hp = player.max_hp
	var health_bar = player.hp_bar
	if hp < 0 or hp > max_hp:
		console.print_to_console("Ошибка: значение вне шкалы здоровья")
		return
	player.current_hp = hp
	health_bar.set_hp(hp)
