extends Node2D

var root_node: map_generator
var tile_size: int =  16

var tilemap: TileMap
var paths: Array = []
var map_x: int = 60
var map_y: int = 30

func _ready():
	tilemap = get_node("TileMap")
	root_node  = map_generator.new(Vector2i(0, 0), Vector2i(map_x, map_y)) #устанавливаем размер карты
	root_node.split(2, paths) #кол-во комнат = 2 в степени первого числа
	queue_redraw()
	pass 

func is_inside_padding(x, y, leaf, padding): #проверка на границу комнаты
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w 

func _draw():
	for x in map_x:
			for y in map_y:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(5,7))
	var rng = RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding = Vector4i(1, 1, 1, 1)
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if not is_inside_padding(x,y, leaf, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 0, Vector2i(2, 2)) #создание комнаты
	for path in paths:
		if path['left'].y == path['right'].y:
			# горизонтальное соединение комнат
			for i in range(path['right'].x - path['left'].x):
				tilemap.set_cell(0, Vector2i(path['left'].x+i,path['left'].y), 0, Vector2i(2, 2))
		else:
			# вертикально соединение комнат
			for i in range(path['right'].y - path['left'].y):
				tilemap.set_cell(0, Vector2i(path['left'].x,path['left'].y+i), 0, Vector2i(2, 2))
