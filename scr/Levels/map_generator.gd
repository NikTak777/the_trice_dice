extends Node
class_name map_generator

var left_child: map_generator
var right_child: map_generator
var position: Vector2i
var size: Vector2i

# Новый массив для хранения комнат при генерации методом Random Walk
var generated_rooms: Array[map_generator] = []

func _init(position: Vector2i, size: Vector2i):
	self.position = position
	self.size = size

func get_center():
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)

func get_corners():
	var corner_top = [position.x + 4, position.y + 4]
	var corner_bottom = [position.x + size.x - 4, position.y + size.y - 4]
	return [corner_top, corner_bottom]

# Обновленный метод получения листьев (комнат)
func get_leaves():
	# Если мы использовали новый генератор и список не пуст — возвращаем его
	if generated_rooms.size() > 0:
		return generated_rooms
	
	# Старая логика (на всякий случай)
	if not (left_child and right_child):
		return [self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

# --- НОВЫЙ АЛГОРИТМ ГЕНЕРАЦИИ (Вместо split) ---
func generate_random_walk(max_rooms: int, min_size: Vector2i, max_size: Vector2i, gap: int):
	var rng = RandomNumberGenerator.new()
	generated_rooms.clear()
	
	# 1. Создаем первую комнату в центре карты (которая задана в init)
	var start_room_size = Vector2i(
		rng.randi_range(min_size.x, max_size.x),
		rng.randi_range(min_size.y, max_size.y)
	)
	# Центрируем первую комнату относительно позиции рута
	var start_pos = Vector2i(
		position.x + (size.x / 2) - (start_room_size.x / 2),
		position.y + (size.y / 2) - (start_room_size.y / 2)
	)
	
	var root_room = map_generator.new(start_pos, start_room_size)
	generated_rooms.append(root_room)
	
	# Выбираем две случайные соседние стороны для генерации
	# 0: Вверх, 1: Вниз, 2: Влево, 3: Вправо
	var horizontal_dir = rng.randi() % 2  # 0 = влево (2), 1 = вправо (3)
	var vertical_dir = rng.randi() % 2    # 0 = вверх (0), 1 = вниз (1)
	
	var allowed_directions = []
	if horizontal_dir == 0:
		allowed_directions.append(2)  # Влево
	else:
		allowed_directions.append(3)  # Вправо
	
	if vertical_dir == 0:
		allowed_directions.append(0)  # Вверх
	else:
		allowed_directions.append(1)  # Вниз
	
	# Вспомогательная сетка, чтобы комнаты не накладывались
	# Храним Rect2i всех созданных комнат + gap
	var occupied_rects: Array[Rect2i] = []
	occupied_rects.append(Rect2i(start_pos, start_room_size))

	var attempts = 0
	var max_attempts = 1000 # Защита от вечного цикла
	
	while generated_rooms.size() < max_rooms and attempts < max_attempts:
		attempts += 1
		
		# 2. Выбираем случайную существующую комнату, от которой будем "расти"
		var base_room = generated_rooms.pick_random()
		
		# 3. Выбираем направление только из разрешенных (две соседние стороны)
		var direction = allowed_directions[rng.randi() % allowed_directions.size()]
		
		# 4. Генерируем размер новой комнаты
		var new_size = Vector2i(
			rng.randi_range(min_size.x, max_size.x),
			rng.randi_range(min_size.y, max_size.y)
		)
		
		var new_pos = Vector2i.ZERO
		
		# Рассчитываем позицию с учетом отступа (gap)
		# Мы добавляем gap к смещению, чтобы между стенами было место для коридора
		match direction:
			0: # Вверх
				new_pos = Vector2i(base_room.position.x + (base_room.size.x - new_size.x) / 2, base_room.position.y - new_size.y - gap)
			1: # Вниз
				new_pos = Vector2i(base_room.position.x + (base_room.size.x - new_size.x) / 2, base_room.position.y + base_room.size.y + gap)
			2: # Влево
				new_pos = Vector2i(base_room.position.x - new_size.x - gap, base_room.position.y + (base_room.size.y - new_size.y) / 2)
			3: # Вправо
				new_pos = Vector2i(base_room.position.x + base_room.size.x + gap, base_room.position.y + (base_room.size.y - new_size.y) / 2)
		
		# Немного сдвигаем комнату перпендикулярно направлению для "неровности" (optional)
		# if direction <= 1: # Вертикально -> сдвиг по X
		# 	new_pos.x += rng.randi_range(-5, 5)
		# else: # Горизонтально -> сдвиг по Y
		#	new_pos.y += rng.randi_range(-5, 5)

		# 5. Проверка на пересечения
		var new_rect = Rect2i(new_pos, new_size)
		# Создаем rect с небольшим запасом (buffer), чтобы комнаты не слипались углами
		var check_rect = new_rect.grow(-2) 
		
		var overlaps = false
		for r in occupied_rects:
			# Проверяем пересечение с учетом gap (grow(gap) делает "ауру" вокруг занятых мест)
			if r.grow(gap - 2).intersects(check_rect):
				overlaps = true
				break
		
		if not overlaps:
			var new_room = map_generator.new(new_pos, new_size)
			generated_rooms.append(new_room)
			occupied_rects.append(new_rect)
			attempts = 0 # Сбрасываем попытки при успехе

# --- Старые методы оставляем как есть, они нужны для Main ---
func get_room_center(room_number):
	var leaves = get_leaves()
	if leaves.size() >= room_number:
		return leaves[room_number - 1].get_center()
	return Vector2i.ZERO 

func get_room_corners(room_number):
	var leaves = get_leaves()
	if leaves.size() >= room_number:
		return leaves[room_number - 1].get_corners()
	return [[0, 0], [0, 0]]

func get_room_bounds(room_number):
	var leaves = get_leaves()
	if leaves.size() >= room_number:
		var room = leaves[room_number - 1]
		var top_left = room.position + Vector2i(1, 1)
		var bottom_right = room.position + room.size - Vector2i(1, 1)
		return [top_left, bottom_right]
	return [[0, 0], [0, 0]]
