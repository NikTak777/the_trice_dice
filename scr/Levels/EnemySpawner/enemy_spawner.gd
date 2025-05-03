# EnemySpawner.gd
extends Node2D

@export var melee_enemy_scene: PackedScene
@export var ranged_enemy_scene: PackedScene
@export var tile_size: int = 16
@export var room_start: int = 2
@export var room_end: int = 8
@export var map_generator: Node  # передаётся из game.gd
@export var room_area_scene: PackedScene  # preload("res://Utils/RoomArea.tscn")

# Словарь, где для каждой комнаты (номер) хранится массив врагов
var room_enemies: Dictionary = {}
@export var enemy_manager: Node       # передается из Game.gd

signal room_cleared(room_number)

func _ready() -> void:
	spawn_enemies()
	spawn_room_areas()

# Функция спавна врагов для каждой комнаты
func spawn_enemies() -> void:
	for room in range(room_start, room_end + 1):
		var room_corners = map_generator.get_room_corners(room)
		var x_min = room_corners[0][0]
		var y_min = room_corners[0][1]
		var x_max = room_corners[1][0]
		var y_max = room_corners[1][1]
		
		# Количество врагов для данной комнаты (можно менять по необходимости)
		var enemy_count = 1 # room + 3
		# Список уже занятых позиций, чтобы избежать наложений
		var used_tiles: Array = []
		var attempts := 0
		var max_attempts := 1000
		
		# Инициализируем массив врагов для этой комнаты
		room_enemies[room] = []
		
		while enemy_count > 0 and attempts < max_attempts:
			attempts += 1
			var tile_x = randi_range(x_min, x_max)
			var tile_y = randi_range(y_min, y_max)
			var tile_pos = Vector2i(tile_x, tile_y)
			
			var valid = true
			for used_tile in used_tiles:
				if tile_pos.distance_to(used_tile) < 2:
					valid = false
					break
			if valid:
				used_tiles.append(tile_pos)
				
				# Выбираем тип врага случайно (50/50)
				var enemy_scene = melee_enemy_scene if randi() % 2 == 0 else ranged_enemy_scene
				var enemy = enemy_scene.instantiate()
				add_child(enemy)
				
				enemy_manager.add_enemy()  # Регистрируем врага в LevelManager
				
				# Устанавливаем позицию в центре выбранного тайла
				var spawn_position = tile_pos * tile_size
				enemy.position = Vector2(spawn_position.x, spawn_position.y)
				enemy.scale = Vector2(1.0, 1.0)
				
				# Добавляем свойство room_number для врага, чтобы знать его комнату
				enemy.set("room_number", room)
				# И изначально враг деактивирован (его логика в _process должна проверять active)
				enemy.set("active", false)
				
				room_enemies[room].append(enemy)
				
				enemy_count -= 1
		if attempts >= max_attempts and enemy_count > 0:
			print("Warning: Не удалось разместить все врагов в комнате ", room)

# Функция создания зон (Area2D) для каждой комнаты, основанных на углах
func spawn_room_areas() -> void:
	for room in range(room_start, room_end + 1):
		# Создаём новый экземпляр зоны для каждой комнаты
		var area_instance = room_area_scene.instantiate()
		area_instance.room_number = room

		# Получаем углы комнаты в клеточных координатах, затем переводим в пиксели:
		var room_corners = map_generator.get_room_bounds(room)
		var top_left = Vector2(room_corners[0][0] * tile_size, room_corners[0][1] * tile_size)
		var bottom_right = Vector2(room_corners[1][0] * tile_size, room_corners[1][1] * tile_size)

		# Вычисляем центр комнаты (в пикселях)
		var room_center = (top_left + bottom_right) / 2.0

		# Помещаем Area2D в центр комнаты
		area_instance.position = room_center

		# Определяем размеры комнаты (в пикселях)
		var room_size = bottom_right - top_left

		# Создаем RectangleShape2D, у которого extents – это половина размеров комнаты
		var shape = RectangleShape2D.new()
		shape.extents = room_size / 2.0

		# Назначаем CollisionShape2D созданную форму
		var collision_shape = area_instance.get_node("CollisionShape2D")
		if collision_shape:
			collision_shape.shape = shape
		else:
			print("Warning: CollisionShape2D не найден в RoomArea!")

		# Добавляем зону в сцену
		add_child(area_instance)

		# Подключаем сигналы
		area_instance.connect("player_entered_room", Callable(self, "_on_player_entered_room"))
		area_instance.connect("player_exited_room", Callable(self, "_on_player_exited_room"))
		
func _check_room_cleared(room_number: int) -> void:
	if room_enemies.has(room_number):
		room_enemies[room_number] = room_enemies[room_number].filter(func(e): return is_instance_valid(e))

		var remaining = room_enemies[room_number].size() - 1  # <- костыль
		print("Оставшиеся враги в комнате", room_number, ":", remaining)

		if remaining <= 0:
			print("Комната очищена: ", room_number)
			emit_signal("room_cleared", room_number)
		
func _on_player_entered_room(room_number: int) -> void:
	print("Игрок вошёл в комнату ", room_number)
	if room_enemies.has(room_number):
		var enemies = room_enemies[room_number]
		# Проходим от конца массива к началу
		for i in range(enemies.size() - 1, -1, -1):
			var enemy = enemies[i]
			if not is_instance_valid(enemy):
				# Если объект уже freed — убираем его из списка
				enemies.remove_at(i)
			else:
				enemy.room_active = true

func _on_player_exited_room(room_number: int) -> void:
	print("Игрок вышел из комнаты ", room_number)
	if room_enemies.has(room_number):
		var enemies = room_enemies[room_number]
		for i in range(enemies.size() - 1, -1, -1):
			var enemy = enemies[i]
			if not is_instance_valid(enemy):
				enemies.remove_at(i)
			else:
				enemy.room_active = false
