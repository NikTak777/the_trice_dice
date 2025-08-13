extends RefCounted

func get_name() -> String: # имя команды, как её будут вызывать
	return "show_nodes"
	
func get_arg_count() -> int: # количество аргументов команды
	return 0
	
func execute(args: Array, console) -> void:
	var player = console.get_tree().get_nodes_in_group("player")[0]
	console.print_to_console("Дерево игрока:")
	_print_node_tree(player, console, "")

# Рекурсивная функция для печати дерева с отступами
func _print_node_tree(node: Node, console, indent: String) -> void:
	console.print_to_console(indent + node.name)
	for child in node.get_children():
		_print_node_tree(child, console, indent + "    ")
