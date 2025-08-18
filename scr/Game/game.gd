extends Node2D

# Предзагрузка ресурсов сцен, используемых в уровне
var player_scene = preload("res://scr/Entities/Player/dice.tscn")
var weapon_spawner_scene = preload("res://scr/Utils/WeaponSpawner/WeaponSpawner.tscn")
var melee_enemy_scene = preload("res://scr/Entities/Enemies/MeleeEnemy/MeleeEnemy.tscn")
var ranged_enemy_scene = preload("res://scr/Entities/Enemies/RangedEnemy/RangedEnemy.tscn")
var hint_scene = preload("res://scr/UserInterface/HintLabel/HintLabel.tscn")
var console = preload("res://scr/Utils/Console/Console.tscn").instantiate()
# var StatisticManager = preload("res://scr/Game/statistic_manager.gd")

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
var health_bar: Node

var hint_label: Node = null

var statistic_manager: Node

# Словарь с направлениями выхода из каждой комнаты (room_number -> Array<Vector2>)
var room_exit_dirs := {}

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_console"):
		console.toggle()
		print("Console")

func _ready():
	
	create_level()
	
	spawn_hint() 

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
	
	init_console()
	
	#statistic_manager = StatisticManager.new()
	#add_child(statistic_manager)
	StatisticManager.start_game()
	
	queue_redraw()
	
func create_level():
	tilemap = get_node("TileMap")
	root_node = map_generator.new(Vector2i(0, 0), Vector2i(map_x, map_y)) # Устанавливаем размер карты
	root_node.split(2) # Кол-во комнат = 2 в степени числа
	
	corridor_graph = CorridorGraph.new()
	corridor_graph.build_corridor_graph(root_node)
	
	map_drawer = MapDrawer.new()
	add_child(map_drawer)  # если нужно
	map_drawer.draw_map(tilemap, root_node, corridor_graph.corridors)
	
func init_console():
	add_child(console)

func spawn_hint():
	hint_label = hint_scene.instantiate()
	add_child(hint_label)

func spawn_player():
	var player = player_scene.instantiate()
	add_child(player)
	
	# Добавляем HealthBar в CanvasLayer (UI)
	var health_bar = preload("res://scr/UserInterface/HealthBar/PlayerHealthBar/PlayerHealthBar.tscn").instantiate()
	var canvas_layer = get_node("CanvasLayer")
	canvas_layer.add_child(health_bar)
	health_bar.position = Vector2(20, 60)
	player.hp_bar = health_bar
	self.health_bar = health_bar
	player.hp_bar.set_max_hp(player.max_hp)
	
	player.change_ability()

	# Позиции
	var spawn_position: Vector2 = root_node.get_room_center(1) * tile_size
	var start_position: Vector2 = spawn_position + Vector2(0, -500)
	player.position = start_position
	player.scale = Vector2(0.125, 0.125)

	# --- Временное отвязывание камеры ---
	var cam: Camera2D = player.get_node("PlayerCamera")
	if cam:
		player.remove_child(cam)
		add_child(cam)

		# Ставим камеру прямо в точку спавна без плавного движения
		cam.global_position = spawn_position
		cam.make_current()
		cam.force_update_transform() # мгновенное обновление позиции

	# Находим спрайт игрока
	var sprite: Sprite2D = null
	if player.has_node("Sprite2D"):
		sprite = player.get_node("Sprite2D")
	
	# --- Анимация падения игрока ---
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", spawn_position, 2.0)
	
		# Анимация вращения (одновременно с падением)
	if sprite:
		var spin_tween = create_tween().set_parallel(true)
		spin_tween.tween_property(sprite, "rotation", sprite.rotation + deg_to_rad(360 * 10), 2.0) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		# Возвращаем в ноль в конце
		spin_tween.tween_property(sprite, "rotation", 0.0, 0.0).set_delay(2.0)

	await tween.finished

	# --- Возвращаем камеру обратно ---
	if cam:
		remove_child(cam)
		player.add_child(cam)
		cam.position = Vector2.ZERO
		cam.make_current()
		cam.force_update_transform()
	
	hint_label.show_hint("Подойди и нажми E, чтобы подобрать оружие", 7.0)

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
	spawner.hint_label = hint_label
	add_child(spawner)
	
	enemy_spawner = spawner
