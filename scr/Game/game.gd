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
var enemy_spawner: Node

var room_exit_dirs := {} # room_number -> Array<Vector2>

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
	
	var door_manager_scene = load("res://scr/Levels/DoorManager/DoorManager.tscn")
	var door_manager = door_manager_scene.instantiate()

	door_manager.map_generator = root_node
	door_manager.enemy_spawner = enemy_spawner
	door_manager.floor_layer = tilemap

	add_child(door_manager)
	
	queue_redraw()

func build_corridor_graph():
	var rooms = []
	for leaf in root_node.get_leaves():
		rooms.append(leaf.get_center())

	corridors.clear()
	
	# Для MST — выбираем первую комнату как стартовую
	var visited = [rooms[0]]
	var unvisited = rooms.duplicate()
	unvisited.erase(rooms[0])
	
	while unvisited.size() > 0:
		var min_dist = INF
		var min_pair = null
		for v in visited:
			for u in unvisited:
				var dist = v.distance_squared_to(u)
				if dist < min_dist:
					min_dist = dist
					min_pair = [v, u]
		if min_pair != null:
			add_corridor_unique(min_pair[0], min_pair[1])
			visited.append(min_pair[1])
			unvisited.erase(min_pair[1])

func add_corridor_unique(a: Vector2i, b: Vector2i):
	var key = [a, b]
	if vector2i_less(b, a):
		key = [b, a]

	for c in corridors:
		if c[0] == key[0] and c[1] == key[1]:
			return

	corridors.append(key)

	# Добавим направление выхода для комнат
	var rooms = root_node.get_leaves()
	var a_idx = get_room_index_by_center(a, rooms)
	var b_idx = get_room_index_by_center(b, rooms)
	
	if a_idx != -1 and b_idx != -1:
		var dir_ab = (b - a).sign()
		var dir_ba = (a - b).sign()

		if not room_exit_dirs.has(a_idx + 1):
			room_exit_dirs[a_idx + 1] = []
		room_exit_dirs[a_idx + 1].append(dir_ab)

		if not room_exit_dirs.has(b_idx + 1):
			room_exit_dirs[b_idx + 1] = []
		room_exit_dirs[b_idx + 1].append(dir_ba)

func get_room_index_by_center(center: Vector2i, rooms: Array) -> int:
	for i in range(rooms.size()):
		if Vector2i(rooms[i].get_center()) == center:
			return i
	return -1

func vector2i_less(a: Vector2i, b: Vector2i) -> bool:
	if a.x < b.x:
		return true
	elif a.x > b.x:
		return false
	else:
		return a.y < b.y


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
	spawner.spawn_weapon_in_room(1, root_node, "Pistol")
	weapon_spawner = spawner

func spawn_enemy():
	var enemy_spawner_scene = preload("res://scr/Levels/EnemySpawner/EnemySpawner.tscn")
	var spawner = enemy_spawner_scene.instantiate()
	spawner.melee_enemy_scene = melee_enemy_scene
	spawner.ranged_enemy_scene = ranged_enemy_scene
	spawner.tile_size = tile_size
	spawner.map_generator = root_node
	spawner.room_area_scene = preload("res://scr/Levels/RoomArea/RoomArea.tscn")
	spawner.enemy_manager = enemy_manager
	spawner.weapon_spawner = weapon_spawner
	add_child(spawner)
	
	enemy_spawner = spawner

func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y \
		or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w

var floor_map := {}

func _draw():
	floor_map.clear()

	var padding = Vector4i(1, 1, 1, 1)
	for leaf in root_node.get_leaves():
		for x in range(leaf.position.x + padding.x, leaf.position.x + leaf.size.x - padding.z):
			for y in range(leaf.position.y + padding.y, leaf.position.y + leaf.size.y - padding.w):
				var pos = Vector2i(x, y)
				tilemap.set_cell(0, pos, 0, Vector2i(2, 2)) # пол
				floor_map[pos] = true

	# Отрисовка коридоров (только один маршрут X → Y)
	for c in corridors:
		var from = c[0]
		var to = c[1]
		var corridor_half_width = 2
		var corner = Vector2i(to.x, from.y)

		# Горизонтальный сегмент
		for x in range(min(from.x, corner.x), max(from.x, corner.x) + 1):
			for dy in range(-corridor_half_width, corridor_half_width):
				var pos = Vector2i(x, from.y + dy)
				tilemap.set_cell(0, pos, 0, Vector2i(2, 2))
				floor_map[pos] = true

		# Вертикальный сегмент
		for y in range(min(corner.y, to.y), max(corner.y, to.y) + 1):
			for dx in range(-corridor_half_width, corridor_half_width):
				var pos = Vector2i(to.x + dx, y)
				tilemap.set_cell(0, pos, 0, Vector2i(2, 2))
				floor_map[pos] = true

	# Стены по краям пола
	var directions = [
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(0, -1), Vector2i(0, 1),
		Vector2i(-1, -1), Vector2i(1, -1),
		Vector2i(-1, 1), Vector2i(1, 1),
	]

	for pos in floor_map.keys():
		for dir in directions:
			var npos = pos + dir
			if not floor_map.has(npos):
				var tile_id = get_wall_tile_id(dir)
				tilemap.set_cell(0, npos, 0, tile_id)

				
func get_wall_tile_id(dir: Vector2i) -> Vector2i:
	# Примерная раскладка, подбери по своей тайл-сетке!
	if dir == Vector2i(-1, 0): return Vector2i(5, 7)  # слева — вертикальная стена
	if dir == Vector2i(1, 0):  return Vector2i(5, 7)  # справа
	if dir == Vector2i(0, -1): return Vector2i(5, 7)  # сверху — горизонтальная
	if dir == Vector2i(0, 1):  return Vector2i(5, 7)  # снизу

	# Диагонали — углы
	if dir == Vector2i(-1, -1): return Vector2i(5, 7) # верх-лево
	if dir == Vector2i(1, -1):  return Vector2i(5, 7) # верх-право
	if dir == Vector2i(-1, 1):  return Vector2i(5, 7) # низ-лево
	if dir == Vector2i(1, 1):   return Vector2i(5, 7) # низ-право

	return Vector2i(5, 7) # default wall
