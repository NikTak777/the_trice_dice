extends Node2D

var player_scene = preload("res://scr/Entities/Player/dice.tscn")
var weapon_spawner_scene = preload("res://scr/Utils/WeaponSpawner/WeaponSpawner.tscn")
var weapon_spawner: Node  # Будем хранить ссылку здесь

var root_node: map_generator
var tile_size: int =  16

var tilemap: TileMap
var paths: Array = []
var map_x: int = 60
var map_y: int = 30

func _ready():
	tilemap = get_node("TileMap")
	
	root_node  = map_generator.new(Vector2i(0, 0), Vector2i(map_x, map_y)) #устанавливаем размер карты
	root_node.split(2, paths) #кол-во комнат = 2 в степени первого числа
	
	spawn_player() # Создание главное героя в игровом уровне
	
	# Создаём экземпляр WeaponSpawner и добавляем в сцену
	weapon_spawner = weapon_spawner_scene.instantiate()
	add_child(weapon_spawner)

	# Вызываем спавн оружия в комнате №2
	weapon_spawner.spawn_weapon_in_room(2, root_node)
	
	queue_redraw()
	pass 
	
func spawn_player():
	var player = player_scene.instantiate()
	add_child(player)

	# Устанавливает позицию персонажа в центр первой комнаты
	var spawn_position = root_node.get_room_center(1) * tile_size
	player.position = Vector2(spawn_position.x, spawn_position.y)
	player.scale = Vector2(0.125, 0.125)
	

func is_inside_padding(x, y, leaf, padding): #проверка на границу комнаты
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w 

func _draw():
	for x in map_x:
			for y in map_y:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(5,7))
	var rng = RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding = Vector4i(1, 1, 1, 1)
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if not is_inside_padding(x,y, leaf, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 0, Vector2i(2, 2)) #создание комнаты
	for path in paths:
		if path['left'].y == path['right'].y:
			# горизонтальное соединение комнат
			for i in range(path['right'].x - path['left'].x):
				tilemap.set_cell(0, Vector2i(path['left'].x+i,path['left'].y), 0, Vector2i(2, 2))
		else:
			# вертикально соединение комнат
			for i in range(path['right'].y - path['left'].y):
				tilemap.set_cell(0, Vector2i(path['left'].x,path['left'].y+i), 0, Vector2i(2, 2))
