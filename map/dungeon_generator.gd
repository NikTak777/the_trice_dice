class_name DungeonGenerator
extends Node

@export_category("Map Dimensions")
@export var map_width: int = 45
@export var map_height: int = 30

@export_category("Rooms RNG")
@export var max_rooms: int = 30
@export var room_max_size: int = 10
@export var room_min_size: int = 6


var _rng := RandomNumberGenerator.new()


func _ready():
	_rng.randomize()


func generate_dungeon(player: Entity) -> MapData: #функция создания подземелья, которая создаёт объект класса MapData
	var dungeon := MapData.new(map_width, map_height)
	var rooms: Array[Rect2i] = [] #отслеживаем созданные комнаты
	for _try_room in max_rooms:
		#рандомим размер комнаты
		var room_width: int = _rng.randi_range(room_min_size, room_max_size)
		var room_height: int = _rng.randi_range(room_min_size, room_max_size)
		#рандомим положение комнаты
		var x: int = _rng.randi_range(0, dungeon.width - room_width - 1)
		var y: int = _rng.randi_range(0, dungeon.height - room_height - 1)
		#создаём комнату и проверяем на наложение
		var new_room := Rect2i(x, y, room_width, room_height)
		var has_intersections := false
		for room in rooms:
			if room.intersects(new_room):
				has_intersections = true
				break
		if has_intersections:
			continue
		#"выкапавыем" комнату
		_carve_room(dungeon, new_room)
		#если это первыя комната, то ставим персонажа в центр
		if rooms.is_empty():
			player.grid_position = new_room.get_center()
		#иначе соединяем туннелем с остальными
		else:
			_tunnel_between(dungeon, rooms.back().get_center(), new_room.get_center())
		rooms.append(new_room)
	return dungeon


func _carve_room(dungeon: MapData, room: Rect2i): #уменьшаем длинну и ширину комнады на 1 и вырезаем её из стены 
	var inner: Rect2i = room.grow(-1)
	for y in range(inner.position.y, inner.end.y + 1):
		for x in range(inner.position.x, inner.end.x + 1):
			_carve_tile(dungeon, x, y)


func _tunnel_horizontal(dungeon: MapData, y: int, x_start: int, x_end: int): #делаем горизонтальные туннели для соединения комнат
	#высота (ака у) остаётся постоянной, так что нам нужно только узнать куда и откуда вести туннель по х
	var x_min: int = mini(x_start, x_end)
	var x_max: int = maxi(x_start, x_end)
	#убедились, что туннель идёт слева направо
	for x in range(x_min, x_max + 1):
		_carve_tile(dungeon, x, y)


func _tunnel_vertical(dungeon: MapData, x: int, y_start: int, y_end: int):
	#широта (ака х) остаётся постоянной, так что нам нужно только узнать куда и откуда вести туннель по у
	var y_min: int = mini(y_start, y_end)
	var y_max: int = maxi(y_start, y_end)
	#убедились, что туннель идёт снизу вверх
	for y in range(y_min, y_max + 1):
		_carve_tile(dungeon, x, y)


func _tunnel_between(dungeon: MapData, start: Vector2i, end: Vector2i): #функция для создания L образных туннелей
	#рандомим направление туннеля
	if _rng.randf() < 0.5:
		_tunnel_horizontal(dungeon, start.y, start.x, end.x)
		_tunnel_vertical(dungeon, end.x, start.y, end.y)
	else:
		_tunnel_vertical(dungeon, start.x, start.y, end.y)
		_tunnel_horizontal(dungeon, end.y, start.x, end.x)


func _carve_tile(dungeon: MapData, x: int, y: int): #меняем тайл стены на тайл пола
		var tile_position = Vector2i(x, y)
		var tile: Tile = dungeon.get_tile(tile_position)
		tile.set_tile_type(dungeon.tile_types.floor)
	
