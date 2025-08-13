extends RefCounted

func get_name() -> String:
	return "zoom"
	
func get_arg_count() -> int:
	return 1

func execute(args: Array, console) -> void:

	var camera_zoom = float(args[0])
	if camera_zoom < 0.001:
		console.print_to_console("Слишком маленькое значение зума")
		return
	if camera_zoom > 100.0:
		console.print_to_console("Слишком большое значение зума")
		return

	var player = console.get_tree().get_nodes_in_group("player")[0]
	var camera = player.get_node("@Camera2D@6")
	camera.zoom = Vector2(camera_zoom, camera_zoom)
	console.print_to_console("Зум установлен: " + str(camera_zoom))
