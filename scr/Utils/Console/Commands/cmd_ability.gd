extends RefCounted

func get_name() -> String: # имя команды, как её будут вызывать
	return "ability"
	
func get_arg_count() -> int: # количество аргументов команды
	return 0
	
func execute(args: Array, console) -> void: # сама логика
	var player = console.get_tree().get_nodes_in_group("player")[0]
	player.change_ability()
