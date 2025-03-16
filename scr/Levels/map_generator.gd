extends Node

class_name map_generator

var left_child:  map_generator
var right_child:  map_generator
var position: Vector2i
var size: Vector2i

func _init(position, size):
	self.position = position
	self.size = size
	
func get_center():
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)

func get_leaves():
	if not (left_child && right_child):
		return [self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

func split(remaining, paths):
	var rng = RandomNumberGenerator.new()
	var split_percent = rng.randf_range(0.4,0.6) #сколько места от сплита будут занимать комнаты
	var split_horizontal = size.y >= size.x # проверка на ориентацию комнаты (горизонтальная или вертикальная)
	if(split_horizontal): #горизонтальная комната
		var left_height = int(size.y * split_percent)
		left_child = map_generator.new(position, Vector2i(size.x, left_height))
		right_child = map_generator.new(
			Vector2i(position.x, position.y + left_height), 
			Vector2i(size.x, size.y - left_height)
		)
	else: #вертикальная комната
		var left_width = int(size.x * split_percent)
		left_child = map_generator.new(position, Vector2i(left_width, size.y))
		right_child = map_generator.new(
			Vector2i(position.x + left_width, position.y), 
			Vector2i(size.x - left_width, size.y))
	paths.push_back({'left': left_child.get_center(), 'right': right_child.get_center()})
	if(remaining > 0):
		left_child.split(remaining - 1, paths)
		right_child.split(remaining - 1, paths)
	pass
