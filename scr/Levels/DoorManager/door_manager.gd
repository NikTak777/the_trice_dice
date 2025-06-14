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

	for x in range(tl.x - 2, br.x + 2):
		for y in range(tl.y - 2, br.y + 2):
			if x == tl.x - 2 or x == br.x + 1 or y == tl.y - 2 or y == br.y + 1:
				var pos = Vector2i(x, y)
				if floor_layer.get_cell_source_id(0, pos) == 0 and floor_layer.get_cell_atlas_coords(0, pos) == Vector2i(2, 2):
					block_layer.set_cell(0, pos, 0, Vector2i(5, 7))

func _open_room(room_number: int) -> void:
	var bounds = map_generator.get_room_bounds(room_number)
	var tl = bounds[0]
	var br = bounds[1]

	for x in range(tl.x - 2, br.x + 2):
		for y in range(tl.y - 2, br.y + 2):
			if x == tl.x - 2 or x == br.x + 1 or y == tl.y - 2 or y == br.y + 1:
				block_layer.set_cell(0, Vector2i(x, y), -1)
