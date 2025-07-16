extends Node2D

# Предзагрузка ресурсов сцен, используемых в уровне
var player_scene = preload("res://scr/Entities/Player/dice.tscn")
var weapon_spawner_scene = preload("res://scr/Utils/WeaponSpawner/WeaponSpawner.tscn")
var melee_enemy_scene = preload("res://scr/Entities/Enemies/MeleeEnemy/MeleeEnemy.tscn")
var ranged_enemy_scene = preload("res://scr/Entities/Enemies/RangedEnemy/RangedEnemy.tscn")

var corridor_graph = preload("res://scr/Levels/corridor_graph.gd").new()
var map_drawer = preload("res://scr/Levels/map_drawer.gd").new()

# Компоненты и параметры карты
var weapon_spawner: Node
var root_node: map_generator
var tile_size: int = 16
var tilemap: TileMap
var corridors: Array = []
var map_x: int = 180
var map_y: int = 80

# Внешние менеджеры
var enemy_manager: Node
var enemy_spawner: Node

# Словарь с направлениями выхода из каждой комнаты (room_number -> Array<Vector2>)
var room_exit_dirs := {}

func _ready():
	tilemap = get_node("TileMap")
	root_node = map_generator.new(Vector2i(0, 0), Vector2i(map_x, map_y)) # Устанавливаем размер карты
	root_node.split(2) # Кол-во комнат = 2 в степени числа
	
	corridor_graph = CorridorGraph.new()
	corridor_graph.build_corridor_graph(root_node)
	
	map_drawer = MapDrawer.new()
	add_child(map_drawer)  # если нужно
	map_drawer.draw_map(tilemap, root_node, corridor_graph.corridors)

	spawn_player() # Создание главное героя в игровом уровне
	spawn_weapons() # Создание оружия в игровом уровне

	var enemy_manager_instance = preload("res://scr/Levels/EnemyManager/EnemyManager.tscn").instantiate()
	enemy_manager_instance.name = "EnemyManager"
	add_child(enemy_manager_instance)
	enemy_manager = enemy_manager_instance
	
	var farthest_room = corridor_graph.get_farthest_room(root_node, 1)

	spawn_enemy(farthest_room)
	
	var door_manager_scene = load("res://scr/Levels/DoorManager/DoorManager.tscn")
	var door_manager = door_manager_scene.instantiate()

	door_manager.map_generator = root_node
	door_manager.enemy_spawner = enemy_spawner
	door_manager.floor_layer = tilemap

	add_child(door_manager)
	
	queue_redraw()

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

func spawn_enemy(room_boss: int):
	var enemy_spawner_scene = preload("res://scr/Levels/EnemySpawner/EnemySpawner.tscn")
	var spawner = enemy_spawner_scene.instantiate()
	spawner.melee_enemy_scene = melee_enemy_scene
	spawner.ranged_enemy_scene = ranged_enemy_scene
	spawner.tile_size = tile_size
	spawner.map_generator = root_node
	spawner.room_area_scene = preload("res://scr/Levels/RoomArea/RoomArea.tscn")
	spawner.enemy_manager = enemy_manager
	spawner.weapon_spawner = weapon_spawner
	spawner.room_boss = room_boss
	add_child(spawner)
	
	enemy_spawner = spawner
