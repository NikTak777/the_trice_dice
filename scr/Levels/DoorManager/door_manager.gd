# DoorManager.gd
extends Node2D

@export var map_generator: map_generator
@export var enemy_spawner: Node

@export var wall_layer: int = 0
@export var wall_tile: int = 0
@export var wall_autotile_coord: Vector2 = Vector2(5,7)

@export var floor_layer: TileMap
@export var floor_tile: int = 1
@export var floor_autotile_coord: Vector2 = Vector2(2,2)

# Добавим новый слой TileMap для преграды
@export var block_layer: TileMap

var _closed_rooms := {}
var cleared_rooms := {}

func _ready():
	if block_layer == null:
		block_layer = $BlockLayer
	print(block_layer)
	print(floor_layer)
	# Подпишемся на все зоны (RoomArea) по группе
	for area in get_tree().get_nodes_in_group("room_area"):
		area.connect("player_entered_room", Callable(self, "_on_player_entered_room"))
	# Подпишемся на сигнал очистки комнаты
	enemy_spawner.connect("room_cleared", Callable(self, "_on_room_cleared"))

func _on_player_entered_room(room_number: int) -> void:
	# Не закрываем, если комната уже зачищена
	if cleared_rooms.has(room_number):
		return

	if not _closed_rooms.has(room_number):
		_closed_rooms[room_number] = true
		_close_room(room_number)

func _on_room_cleared(room_number: int) -> void:
	if _closed_rooms.has(room_number):
		_open_room(room_number)
		_closed_rooms.erase(room_number)
	cleared_rooms[room_number] = true

func _close_room(room_number: int) -> void:
	var bounds = map_generator.get_room_bounds(room_number)
	var tl = bounds[0]
	var br = bounds[1]

	var door_columns := {}
	var door_rows := {}

	# 1. Ставим двери и собираем координаты для анализа направлений
	for x in range(tl.x - 2, br.x + 2):
		for y in range(tl.y - 2, br.y + 2):
			if x == tl.x - 2 or x == br.x + 1 or y == tl.y - 2 or y == br.y + 1:
				var pos = Vector2i(x, y)
				if floor_layer.get_cell_source_id(0, pos) == 0 and floor_layer.get_cell_atlas_coords(0, pos) == Vector2i(2, 2):
					block_layer.set_cell(0, pos, 0, Vector2i(5, 7))
					
					# по x — вертикальная дверь
					if not door_columns.has(x):
						door_columns[x] = []
					door_columns[x].append(y)

					# по y — горизонтальная дверь
					if not door_rows.has(y):
						door_rows[y] = []
					door_rows[y].append(x)

	# 2. Объём для вертикальных дверей (верхний тайл)
	for x in door_columns.keys():
		var ys = door_columns[x]
		ys.sort()
		for i in range(ys.size() - 3):
			if ys[i+1] == ys[i]+1 and ys[i+2] == ys[i]+2 and ys[i+3] == ys[i]+3:
				var top_pos = Vector2i(x, ys[i] - 1)
				block_layer.set_cell(0, top_pos, 0, Vector2i(5, 7))  # дополнительный тайл сверху

	# 3. Объём для горизонтальных дверей (нижний тайл)
	for y in door_rows.keys():
		var xs = door_rows[y]
		xs.sort()
		for i in range(xs.size() - 3):
			if xs[i+1] == xs[i]+1 and xs[i+2] == xs[i]+2 and xs[i+3] == xs[i]+3:
				for j in range(4):
					var bottom_pos = Vector2i(xs[i] + j, y + 1)
					block_layer.set_cell(0, bottom_pos, 0, Vector2i(7, 1))  # дополнительный тайл снизу


func _open_room(room_number: int) -> void:
	var bounds = map_generator.get_room_bounds(room_number)
	var tl = bounds[0]
	var br = bounds[1]

	for x in range(tl.x - 2, br.x + 2):
		for y in range(tl.y - 2, br.y + 2):
			# Основной периметр
			if x == tl.x - 2 or x == br.x + 1 or y == tl.y - 2 or y == br.y + 1:
				block_layer.set_cell(0, Vector2i(x, y), -1)

	# Дополнительно удалим возможные "объёмные" тайлы:
	for x in range(tl.x - 2, br.x + 2):
		for y in range(tl.y - 3, br.y + 3):  # +1 вверх и вниз
			var pos_above = Vector2i(x, y - 1)
			var pos_below = Vector2i(x, y + 1)
			# Удаляем возможный горизонтальный объём (снизу)
			if block_layer.get_cell_atlas_coords(0, pos_below) == Vector2i(5, 7):
				block_layer.set_cell(0, pos_below, -1)
