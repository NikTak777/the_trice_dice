extends Node
class_name map_generator

var left_child: map_generator
var right_child: map_generator
var position: Vector2i
var size: Vector2i

func _init(position: Vector2i, size: Vector2i):
	self.position = position
	self.size = size

func get_center():
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)

func get_corners():
	var corner_top = [position.x + 4, position.y + 4]
	var corner_bottom = [position.x + size.x - 4, position.y + size.y - 4]
	return [corner_top, corner_bottom]

func get_leaves():
	if not (left_child and right_child):
		return [self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

func split(remaining: int):
	var rng = RandomNumberGenerator.new()
	var split_percent = rng.randf_range(0.4, 0.5) # Сколько места от сплита будут занимать комнаты
	var gap = 15 # Расстояние между конматами
	var split_horizontal = size.y >= size.x # Проверка на ориентацию комнаты (горизонтальная или вертикальная)

	if split_horizontal: # Горизонтальная комната
		var left_height = int(size.y * split_percent)
		left_child = map_generator.new(position, Vector2i(size.x, left_height - gap / 2))
		right_child = map_generator.new(
			Vector2i(position.x, position.y + left_height + gap / 2),
			Vector2i(size.x, size.y - left_height - gap)
		)
	else: # Вертикальная комната
		var left_width = int(size.x * split_percent)
		left_child = map_generator.new(position, Vector2i(left_width - gap / 2, size.y))
		right_child = map_generator.new(
			Vector2i(position.x + left_width + gap / 2, position.y),
			Vector2i(size.x - left_width - gap, size.y)
		)

	if remaining > 0:
		left_child.split(remaining - 1)
		right_child.split(remaining - 1)

func get_room_center(room_number):
	var leaves = get_leaves()
	if leaves.size() >= room_number:
		return leaves[room_number - 1].get_center()
	return Vector2i.ZERO # Возвращаем (0,0), если нет комнат или выбранная несуществующая комната

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
