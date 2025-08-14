extends RefCounted

func get_name() -> String: # имя команды, как её будут вызывать
	return "help"
	
func get_arg_count() -> int: # количество аргументов команды
	return 0
	
func execute(args: Array, console) -> void: # сама логика
	console.print_to_console("Доступные команды:")
	for cmd in console.commands.keys():
			console.print_to_console(" - " + cmd)
