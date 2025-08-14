extends RefCounted

func get_name() -> String: # имя команды, как её будут вызывать
	return "restart"
	
func get_arg_count() -> int: # количество аргументов команды
	return 0
	
func execute(args: Array, console) -> void: # сама логика
		console.toggle()
		console.get_tree().reload_current_scene()
