extends Node2D

var player_scene = preload("res://scr/Entities/Player/dice.tscn")
var weapon_spawner_scene = preload("res://scr/Utils/WeaponSpawner/WeaponSpawner.tscn")
var melee_enemy_scene = preload("res://scr/Entities/Enemies/MeleeEnemy/MeleeEnemy.tscn")
var ranged_enemy_scene = preload("res://scr/Entities/Enemies/RangedEnemy/RangedEnemy.tscn")

var weapon_spawner: Node
var root_node: map_generator
var tile_size: int = 16
var tilemap: TileMap
var corridors: Array = []
var map_x: int = 180
var map_y: int = 80

@export var enemy_manager: Node

func _ready():
	tilemap = get_node("TileMap")
	root_node = map_generator.new(Vector2i(0, 0), Vector2i(map_x, map_y)) # Устанавливаем размер карты
	root_node.split(2) # Кол-во комнат = 2 в степени числа

	build_corridor_graph()

	spawn_player() # Создание главное героя в игровом уровне
	spawn_weapons() # Создание оружия в игровом уровне

	var enemy_manager_instance = preload("res://scr/Levels/EnemyManager/EnemyManager.tscn").instantiate()
	enemy_manager_instance.name = "EnemyManager"
	add_child(enemy_manager_instance)
	enemy_manager = enemy_manager_instance

	spawn_enemy()
	queue_redraw()

func build_corridor_graph():
	var rooms = []
	for leaf in root_node.get_leaves():
		rooms.append(leaf.get_center())

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var unvisited = rooms.duplicate()
	var visited = []
	corridors.clear()

	# Из первой комнаты ровно один путь
	visited.append(unvisited[0])
	unvisited.remove_at(0)
	var to_first = unvisited[rng.randi_range(0, unvisited.size() - 1)]
	corridors.append({'from': visited[0], 'to': to_first})
	visited.append(to_first)
	unvisited.erase(to_first)

	# Дерево без возвращений в первую
	while unvisited.size() > 0:
		# выбираем случайную комнату из visited[1..] (чтобы первая не давала новых веток)
		var idx_v = rng.randi_range(1, visited.size() - 1)
		var from = visited[idx_v]
		var idx_u = rng.randi_range(0, unvisited.size() - 1)
		var to = unvisited[idx_u]
		corridors.append({'from': from, 'to': to})
		visited.append(to)
		unvisited.remove_at(idx_u)

func spawn_player():
	var player = player_scene.instantiate()
	add_child(player)
	var spawn_position = root_node.get_room_center(1) * tile_size
	player.position = Vector2(spawn_position)
	player.scale = Vector2(0.125, 0.125)
	player.change_ability()

	var hint = preload("res://scr/UserInterface/HintLabel/HintLabel.tscn").instantiate()
	add_child(hint)
	hint.show_hint("Подойди и нажми E, чтобы подобрать оружие", 7.0)

func spawn_weapons():
	var spawner = weapon_spawner_scene.instantiate()
	add_child(spawner)
	spawner.spawn_weapon_in_room(2, root_node, "Shotgun")
	spawner.spawn_weapon_in_room(3, root_node, "Automat")
	spawner.spawn_weapon_in_room(1, root_node, "Pistol")

func spawn_enemy():
	var enemy_spawner_scene = preload("res://scr/Levels/EnemySpawner/EnemySpawner.tscn")
	var enemy_spawner = enemy_spawner_scene.instantiate()
	enemy_spawner.melee_enemy_scene = melee_enemy_scene
	enemy_spawner.ranged_enemy_scene = ranged_enemy_scene
	enemy_spawner.tile_size = tile_size
	enemy_spawner.map_generator = root_node
	enemy_spawner.room_area_scene = preload("res://scr/Levels/RoomArea/RoomArea.tscn")
	enemy_spawner.enemy_manager = enemy_manager
	add_child(enemy_spawner)

func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y \
		or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w

func _draw():
	# Заполнение карты стенами
	for x in range(map_x):
		for y in range(map_y):
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(5, 7))

	# Отрисовка комнат
	var padding = Vector4i(1, 1, 1, 1)
	for leaf in root_node.get_leaves():
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if not is_inside_padding(x, y, leaf, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(2, 2))

	# Отрисовка коридоров
	for c in corridors:
		var from = c.from
		var to   = c.to

		# L-образный маршрут: по X
		for x in range(min(from.x, to.x), max(from.x, to.x) + 1):
			for dy in range(-2, 2):  # -2, -1, 0, 1 => 4 тайла
				tilemap.set_cell(0, Vector2i(x, from.y + dy), 0, Vector2i(2, 2))

		# по Y
		for y in range(min(from.y, to.y), max(from.y, to.y) + 1):
			for dx in range(-2, 2):
				tilemap.set_cell(0, Vector2i(to.x + dx, y), 0, Vector2i(2, 2))
