extends Control

# Цвета для отрисовки
const COLOR_EXPLORED_ROOM = Color(0.5, 0.5, 0.5, 0.8)  # Серый для изведанных комнат
const COLOR_CURRENT_ROOM = Color(0.2, 0.8, 0.2, 1.0)  # Зеленый для текущей комнаты
const COLOR_CORRIDOR = Color(0.4, 0.4, 0.4, 0.6)  # Серый для коридоров
const COLOR_BACKGROUND = Color(0.0, 0.0, 0.0, 0.0)  # Прозрачный фон (убран темный фон)

# Размеры элементов миникарты
const ROOM_SIZE = 24.0  # Размер квадрата комнаты (увеличен)
const CORRIDOR_WIDTH = 8.0  # Ширина коридора (палочки)
const CORRIDOR_LENGTH = 32.0  # Длина коридора (как размер комнаты)

var root_node: map_generator = null
var corridor_graph: CorridorGraph = null
var explored_rooms: Array[int] = []  # Массив номеров изведанных комнат
var current_room: int = 1  # Текущая комната игрока

# Кэш для координат комнат на миникарте
var room_positions: Dictionary = {}  # room_number -> Vector2 (позиция на миникарте)
var room_centers: Dictionary = {}  # room_number -> Vector2i (центр комнаты в игровых координатах)

func _ready():
	# Изначально открыта только стартовая комната
	explored_rooms = [1]
	current_room = 1

func initialize(map_gen: map_generator, corridors: CorridorGraph):
	root_node = map_gen
	corridor_graph = corridors
	_calculate_room_positions()
	# Уведомляем миникарту о начальной комнате
	on_player_entered_room(1)
	queue_redraw()

func _calculate_room_positions():
	"""Вычисляет позиции комнат на миникарте с учетом масштабирования"""
	if not root_node:
		return
	
	var rooms = root_node.get_leaves()
	if rooms.size() == 0:
		return
	
	# Находим границы всех комнат
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	room_centers.clear()
	for i in range(rooms.size()):
		var room = rooms[i]
		var center = room.get_center()
		room_centers[i + 1] = center  # Комнаты нумеруются с 1
		
		min_x = min(min_x, center.x)
		max_x = max(max_x, center.x)
		min_y = min(min_y, center.y)
		max_y = max(max_y, center.y)
	
	# Минимальное расстояние между центрами комнат на миникарте (чтобы квадраты не перекрывались)
	var min_distance_on_minimap = ROOM_SIZE * 1.8  # Минимум 1.8 размера комнаты между центрами
	
	# Вычисляем реальные расстояния между комнатами
	var real_width = max_x - min_x
	var real_height = max_y - min_y
	
	var minimap_size = size
	if minimap_size.x <= 0 or minimap_size.y <= 0:
		minimap_size = Vector2(220, 250)  # Увеличен размер по умолчанию
	
	# Увеличенные отступы для лучшей видимости
	var padding_left = 15.0
	var padding_right = 15.0
	var padding_top = 15.0
	var padding_bottom = 15.0
	
	var available_width = minimap_size.x - padding_left - padding_right
	var available_height = minimap_size.y - padding_top - padding_bottom
	
	# Вычисляем минимальный масштаб на основе минимального расстояния между комнатами
	var min_scale = 1.0
	if rooms.size() > 1 and (real_width > 0 or real_height > 0):
		# Находим минимальное реальное расстояние между комнатами
		var min_real_distance = INF
		for i in range(rooms.size()):
			for j in range(i + 1, rooms.size()):
				var center1 = rooms[i].get_center()
				var center2 = rooms[j].get_center()
				var dist = Vector2(center1.x - center2.x, center1.y - center2.y).length()
				if dist > 0:
					min_real_distance = min(min_real_distance, dist)
		
		# Вычисляем минимальный масштаб, чтобы расстояние на миникарте было достаточным
		if min_real_distance < INF:
			min_scale = min_distance_on_minimap / min_real_distance
	
	# Обычный масштаб для размещения всех комнат
	var scale_x = available_width / real_width if real_width > 0 else 1.0
	var scale_y = available_height / real_height if real_height > 0 else 1.0
	var scale = min(scale_x, scale_y)
	
	# Используем больший масштаб из двух: для размещения всех комнат или для минимального расстояния
	scale = max(scale, min_scale)
	
	# Вычисляем позиции комнат на миникарте с учетом отступов
	room_positions.clear()
	for room_num in room_centers.keys():
		var center = room_centers[room_num]
		var x = (center.x - min_x) * scale + padding_left
		var y = (center.y - min_y) * scale + padding_top
		room_positions[room_num] = Vector2(x, y)

func _draw():
	if not root_node or not corridor_graph:
		return
	
	# Рисуем фон
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BACKGROUND)
	
	# Рисуем коридоры между изведанными комнатами
	_draw_corridors()
	
	# Рисуем комнаты
	_draw_rooms()

func _draw_corridors():
	"""Отрисовывает коридоры между изведанными комнатами"""
	for corridor in corridor_graph.corridors:
		var from_center = corridor[0]
		var to_center = corridor[1]
		
		# Находим номера комнат по их центрам
		var from_room = _get_room_by_center(from_center)
		var to_room = _get_room_by_center(to_center)
		
		# Рисуем коридор только если обе комнаты изведаны
		if from_room != -1 and to_room != -1:
			if explored_rooms.has(from_room) and explored_rooms.has(to_room):
				var from_pos = room_positions.get(from_room, Vector2.ZERO)
				var to_pos = room_positions.get(to_room, Vector2.ZERO)
				
				if from_pos != Vector2.ZERO and to_pos != Vector2.ZERO:
					# Рисуем L-образный коридор как вытянутые палочки
					_draw_l_corridor(from_pos, to_pos)

func _draw_l_corridor(from: Vector2, to: Vector2):
	"""Отрисовывает L-образный коридор как вытянутые палочки"""
	# Определяем угол поворота (сначала горизонтально, потом вертикально)
	var corner = Vector2(to.x, from.y)
	
	# Горизонтальная часть (от первой комнаты до угла)
	var dir_h = corner - from
	if abs(dir_h.x) > 0.1:
		var start_x = from.x + sign(dir_h.x) * (ROOM_SIZE / 2)
		var end_x = corner.x - sign(dir_h.x) * (ROOM_SIZE / 2)
		var length_h = abs(end_x - start_x)
		if length_h > 0.1:
			var rect_h = Rect2(
				Vector2(min(start_x, end_x), from.y - CORRIDOR_WIDTH / 2),
				Vector2(length_h, CORRIDOR_WIDTH)
			)
			draw_rect(rect_h, COLOR_CORRIDOR)
	
	# Вертикальная часть (от угла до второй комнаты)
	var dir_v = to - corner
	if abs(dir_v.y) > 0.1:
		var start_y = corner.y + sign(dir_v.y) * (ROOM_SIZE / 2)
		var end_y = to.y - sign(dir_v.y) * (ROOM_SIZE / 2)
		var length_v = abs(end_y - start_y)
		if length_v > 0.1:
			var rect_v = Rect2(
				Vector2(to.x - CORRIDOR_WIDTH / 2, min(start_y, end_y)),
				Vector2(CORRIDOR_WIDTH, length_v)
			)
			draw_rect(rect_v, COLOR_CORRIDOR)

func _draw_rooms():
	"""Отрисовывает комнаты"""
	for room_num in room_positions.keys():
		if explored_rooms.has(room_num):
			var pos = room_positions[room_num]
			var room_rect = Rect2(pos - Vector2(ROOM_SIZE / 2, ROOM_SIZE / 2), Vector2(ROOM_SIZE, ROOM_SIZE))
			
			# Выбираем цвет в зависимости от того, является ли комната текущей
			var color = COLOR_CURRENT_ROOM if room_num == current_room else COLOR_EXPLORED_ROOM
			draw_rect(room_rect, color)
			
			# Рисуем обводку
			draw_rect(room_rect, Color.WHITE, false, 1.0)

func _get_room_by_center(center: Vector2i) -> int:
	"""Возвращает номер комнаты по её центру"""
	for room_num in room_centers.keys():
		if room_centers[room_num] == center:
			return room_num
	return -1

func on_player_entered_room(room_number: int):
	"""Вызывается когда игрок входит в комнату"""
	if not explored_rooms.has(room_number):
		explored_rooms.append(room_number)
	current_room = room_number
	queue_redraw()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		# Пересчитываем позиции при изменении размера
		if root_node:
			_calculate_room_positions()
			queue_redraw()

