extends CanvasLayer

@onready var log_output: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var input_field: LineEdit = $PanelContainer/VBoxContainer/LineEdit

var commands := {}

var is_console_open: bool = false

func _ready():
	# Увеличиваем размеры
	log_output.custom_minimum_size = Vector2(600, 400) # ширина и высота
	input_field.custom_minimum_size = Vector2(600, 30)
	$PanelContainer.position.y = 100
	
	visible = false
	input_field.connect("text_submitted", Callable(self, "_on_command_entered"))
	register_default_commands()

func toggle():
	visible = !visible
	# get_tree().paused = visible
	Global.is_console_open = visible
	if visible:
		input_field.grab_focus() # курсор сразу в поле
	else:
		get_viewport().set_input_as_handled() # сброс ввода

func register_command(name: String, func_ref: Callable):
	commands[name] = func_ref

func register_default_commands():
	register_command("help", func() -> void:
		for cmd in commands.keys():
			print_to_console(cmd)
	)

	register_command("clear", func() -> void:
		log_output.clear()
	)
	
	register_command("give", func(weapon_name: String) -> void:
		var player = get_tree().get_nodes_in_group("player")[0]
		var weapon_factory_scene = preload("res://scr/Utils/WeaponFactory/WeaponFactory.tscn")
		var weapon_factory = weapon_factory_scene.instantiate()
		add_child(weapon_factory)
		
		if weapon_name == "help":
			var weapon_list = weapon_factory.weapon_data.keys()
			print_to_console("Доступное оружие:")
			for w in weapon_list:
				print_to_console(" - " + w)
			return
			
		if not weapon_factory.weapon_data.has(weapon_name):
			print_to_console("Ошибка: оружие '" + weapon_name + "' не найдено.")
			weapon_factory.queue_free()
			return
		
		var new_weapon = weapon_factory.create_weapon(weapon_name)
		add_child(new_weapon)
		player.inventory.pickup_weapon(new_weapon)
		new_weapon.equip()
		player.nearby_weapon = null
		
		print_to_console("Игроку выдано оружие " + weapon_name)
	)
	
	register_command("zoom", func(camera_zoom) -> void:
		camera_zoom = float(camera_zoom)
		if camera_zoom < 0.001:
			print_to_console("Слишком маленькое значение зума")
			return
		if camera_zoom > 100.0:
			print_to_console("Слишком большое значение зума")
			return
		var player = get_tree().get_nodes_in_group("player")[0]
		var camera = player.get_node("@Camera2D@6")
		camera.zoom = Vector2(camera_zoom, camera_zoom)
	)
	
	register_command("show_nodes", func() -> void:
		var player = get_tree().get_nodes_in_group("player")[0]
		print_to_console("Дерево игрока:")
		print_node_tree(player)
	)
	
	register_command("restart", func() -> void:
		toggle()
		get_tree().reload_current_scene()
	)
	
	register_command("kill", func(room_number) -> void:
		var enemy_spawner = get_parent().enemy_spawner
		if room_number == "all":
			for i in range(2,9):
				enemy_spawner.kill_room_enemies(int(i))
		else:
			enemy_spawner.kill_room_enemies(int(room_number))
	)

func print_node_tree(node: Node, prefix: String = ""):
	print_to_console(prefix + node.name)
	for child in node.get_children():
		print_node_tree(child, prefix + "  ")

func _on_command_entered(command: String):
	if command.strip_edges() == "":
		return

	var parts = command.strip_edges().split(" ")
	var cmd = parts[0]
	var args = parts.slice(1, parts.size())

	if commands.has(cmd):
		var func_ref: Callable = commands[cmd]
		var expected_args = func_ref.get_argument_count()

		if args.size() < expected_args:
			print_to_console("Ошибка: команда '%s' требует %d аргумент(ов), введено %d" % [cmd, expected_args, args.size()])
			return

		func_ref.callv(args)
	else:
		print_to_console("Неизвестная команда: " + cmd)

	input_field.text = ""

func print_to_console(text: String):
	log_output.append_text(text + "\n")
