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
var mana_label: Node

var hint_label: Node = null
var hint_manager: HintManager = null

var statistic_manager: Node

# Миникарта
var minimap: Control = null

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
	
	spawn_minimap()
	
	# Подключаем сигналы миникарты после создания всех RoomArea
	await get_tree().process_frame  # Ждем один кадр, чтобы RoomArea успели создаться
	_connect_minimap_signals()

	StatisticManager.start_game()
	
	queue_redraw()
	
func create_level():
	tilemap = get_node("TileMap")
	
	root_node = map_generator.new(Vector2i(0, 0), Vector2i(1, 1)) 
	
	# НАСТРОЙКИ ГЕНЕРАЦИИ
	var rooms_count = 9          # Количество комнат
	var min_room_size = Vector2i(30, 30)
	var max_room_size = Vector2i(30, 30)
	var gap_size = 20         # Расстояние между комнатами (длина коридора)
	
	root_node.generate_random_walk(rooms_count, min_room_size, max_room_size, gap_size)
	
	corridor_graph = CorridorGraph.new()
	corridor_graph.build_corridor_graph(root_node)
	
	map_drawer = MapDrawer.new()
	add_child(map_drawer)
	map_drawer.draw_map(tilemap, root_node, corridor_graph.corridors)
	
func init_console():
	add_child(console)

func spawn_hint():
	hint_label = hint_scene.instantiate()
	add_child(hint_label)
	
	# Создаем и инициализируем менеджер подсказок
	hint_manager = preload("res://scr/Utils/HintManager/hint_manager.gd").new()
	hint_manager.set_hint_label(hint_label)
	add_child(hint_manager)

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
	
	# Mana label
	var mana_label = preload(
		"res://scr/UserInterface/ManaBar/ManaText.tscn"
	).instantiate()
	canvas_layer.add_child(mana_label)
	mana_label.position = Vector2(20, 100)
	player.mana_manager.mana_changed.connect(mana_label.set_mana)
	
	mana_label.set_mana(
		player.mana_manager.current_value,
		player.mana_manager.max_value
	)
	
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
	
	# Устанавливаем флаг, что персонаж находится в процессе спавна
	player.is_spawning = true
	
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
	
	# Помечаем, что спавн завершён
	player.is_spawning = false

	# --- Возвращаем камеру обратно ---
	if cam:
		remove_child(cam)
		player.add_child(cam)
		cam.position = Vector2.ZERO
		cam.make_current()
		cam.force_update_transform()
	
	hint_manager.show_hint("pickup_weapon", 7.0)

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
	spawner.hint_manager = hint_manager
	
	# Автоматически устанавливаем количество комнат для спавна врагов
	# Комната 1 - стартовая (где игрок), поэтому враги начинаются с комнаты 2
	spawner.room_start = 2
	# room_end устанавливаем равным общему количеству комнат
	var total_rooms = root_node.get_leaves().size()
	spawner.room_end = total_rooms
	
	add_child(spawner)
	
	enemy_spawner = spawner

func spawn_minimap():
	"""Создает и инициализирует миникарту"""
	var minimap_scene = preload("res://scr/UserInterface/Minimap/Minimap.tscn")
	minimap = minimap_scene.instantiate()
	
	# Добавляем миникарту в CanvasLayer (UI)
	var canvas_layer = get_node("CanvasLayer")
	canvas_layer.add_child(minimap)
	
	# Позиционируем миникарту в правом верхнем углу с отступами
	var margin_right = 20  # Отступ справа
	var margin_top = 20     # Отступ сверху
	var minimap_width = 220
	var minimap_height = 250  # Увеличена высота для лучшей видимости коридоров
	
	minimap.anchor_left = 1.0
	minimap.anchor_top = 0.0
	minimap.anchor_right = 1.0
	minimap.anchor_bottom = 0.0
	minimap.offset_left = -minimap_width - margin_right
	minimap.offset_top = margin_top
	minimap.offset_right = -margin_right
	minimap.offset_bottom = minimap_height + margin_top
	
	# Инициализируем миникарту данными о карте
	minimap.initialize(root_node, corridor_graph)

func _connect_minimap_signals():
	"""Подключает сигналы входа в комнату к миникарте"""
	if not minimap:
		return
	
	# Подключаем сигналы входа в комнату к миникарте
	for area in get_tree().get_nodes_in_group("room_area"):
		if not area.is_connected("player_entered_room", Callable(minimap, "on_player_entered_room")):
			area.connect("player_entered_room", Callable(minimap, "on_player_entered_room"))
