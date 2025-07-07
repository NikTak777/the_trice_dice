class_name MapDrawer

extends Node

var floor_map := {}

enum FloorType { NONE, ROOM, CORRIDOR }
var floor_type := {}  # Map<Vector2i, FloorType>
const FOUNDATION_TILE = Vector2i(5, 3)  # Координаты тайла основания (настройте под ваш тайлсет)

var bottom_wall_positions: Array = []
var top_wall_positions:    Array = []

var external_corner_nw: Array = []
var external_corner_ne: Array = []
var external_corner_sw: Array = []
var external_corner_se: Array = []

var internal_corner_nw: Array = []
var internal_corner_ne: Array = []
var internal_corner_sw: Array = []
var internal_corner_se: Array = []

func draw_map(tilemap: TileMap, root_node, corridors: Array):
	floor_type.clear()
	tilemap.clear()
	bottom_wall_positions.clear()
	top_wall_positions.clear()
	external_corner_nw.clear(); external_corner_ne.clear()
	external_corner_sw.clear(); external_corner_se.clear()
	internal_corner_nw.clear(); internal_corner_ne.clear()
	internal_corner_sw.clear(); internal_corner_se.clear()

	# 1) Отрисовка полов (комнаты и коридоры)
	var padding = Vector4i(1,1,1,1)
	for leaf in root_node.get_leaves():
		for x in range(leaf.position.x + padding.x, leaf.position.x + leaf.size.x - padding.z):
			for y in range(leaf.position.y + padding.y, leaf.position.y + leaf.size.y - padding.w):
				var p = Vector2i(x,y)
				tilemap.set_cell(0, p, 0, Vector2i(2,2))
				floor_type[p] = FloorType.ROOM

	for c in corridors:
		var from = c[0]; var to = c[1]
		var corner = Vector2i(to.x, from.y)
		for x in range(min(from.x, corner.x), max(from.x, corner.x)+1):
			for dy in range(-2,2):
				var p = Vector2i(x, from.y+dy)
				tilemap.set_cell(0, p, 0, Vector2i(2,2))
				floor_type[p] = FloorType.CORRIDOR
		for y in range(min(corner.y, to.y), max(corner.y, to.y)+1):
			for dx in range(-2,2):
				var p = Vector2i(to.x+dx, y)
				tilemap.set_cell(0, p, 0, Vector2i(2,2))
				floor_type[p] = FloorType.CORRIDOR

	# 2) Отрисовка внутренних углов
	var corner_dirs = {
		Vector2i(-1,-1): [Vector2i(-1,0), Vector2i(0,-1)],
		Vector2i( 1,-1): [Vector2i( 1,0), Vector2i(0,-1)],
		Vector2i(-1, 1): [Vector2i(-1,0), Vector2i(0, 1)],
		Vector2i( 1, 1): [Vector2i( 1,0), Vector2i(0, 1)],
	}
	for pos in floor_type.keys():
		for diag in corner_dirs.keys():
			var wpos = pos + diag
			if tilemap.get_cell_atlas_coords(0, wpos) != Vector2i(-1,-1):
				continue
			var needs = corner_dirs[diag]
			var ft1 = floor_type.get(pos + needs[0], FloorType.NONE)
			var ft2 = floor_type.get(pos + needs[1], FloorType.NONE)
			if ft1 != FloorType.NONE and ft2 != FloorType.NONE:
				if ft1 != ft2:
					tilemap.set_cell(0, wpos, 0, get_internal_corner_tile_id(diag))
					match diag:
						Vector2i(-1,-1): internal_corner_nw.append(wpos)
						Vector2i( 1,-1): internal_corner_ne.append(wpos)
						Vector2i(-1, 1): internal_corner_sw.append(wpos)
						Vector2i( 1, 1): internal_corner_se.append(wpos)
				else:
					tilemap.set_cell(0, wpos, 0, get_wall_tile_id(diag))

	# 3) Основные стены (прямые)
	var straight = [Vector2i(-1,0), Vector2i(1,0), Vector2i(0,-1), Vector2i(0,1)]
	for pos in floor_type.keys():
		for d in straight:
			var wpos = pos + d
			if tilemap.get_cell_atlas_coords(0, wpos) == Vector2i(-1, -1):
				tilemap.set_cell(0, wpos, 0, get_wall_tile_id(d))
				if d == Vector2i(0,1):
					bottom_wall_positions.append(wpos)
				if d == Vector2i(0,-1):
					top_wall_positions.append(wpos)
					

	# 4) Отрисовка ВНЕШНИХ УГЛОВ
	var external_corners = [
		Vector2i(-1, -1), Vector2i(1, -1),
		Vector2i(-1, 1), Vector2i(1, 1)
	]

	for pos in floor_type.keys():
		for diag in external_corners:
			var wpos = pos + diag
			if tilemap.get_cell_atlas_coords(0, wpos) != Vector2i(-1,-1):
				continue
				
			var check_dirs = []
			if diag == Vector2i(-1,-1):
				check_dirs = [Vector2i(1,0), Vector2i(0,1)]
			elif diag == Vector2i(1,-1):
				check_dirs = [Vector2i(-1,0), Vector2i(0,1)]
			elif diag == Vector2i(-1,1):
				check_dirs = [Vector2i(1,0), Vector2i(0,-1)]
			elif diag == Vector2i(1,1):
				check_dirs = [Vector2i(-1,0), Vector2i(0,-1)]
			
			var neighbor1 = wpos + check_dirs[0]
			var neighbor2 = wpos + check_dirs[1]
			
			if tilemap.get_cell_atlas_coords(0, neighbor1) != Vector2i(-1,-1) and \
			   tilemap.get_cell_atlas_coords(0, neighbor2) != Vector2i(-1,-1):
				# Используем функцию для ВНЕШНИХ углов
				tilemap.set_cell(0, wpos, 0, get_external_corner_tile_id(diag))
				match diag:
					Vector2i(-1,-1): external_corner_nw.append(wpos)
					Vector2i( 1,-1): external_corner_ne.append(wpos)
					Vector2i(-1, 1): external_corner_sw.append(wpos)
					Vector2i( 1, 1): external_corner_se.append(wpos)
	
	# Блок отрисовки дополнительных стен
	for wpos in bottom_wall_positions:
		wpos += Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_wall_tile_id(Vector2i(0,1)))
	for wpos in top_wall_positions:
		wpos += Vector2i(0,-1)
		tilemap.set_cell(0, wpos, 0, get_extra_wall_tile_id(Vector2i(0,-1)))
		
	# Блок отрисовки внешних углов
	for wpos in external_corner_nw:
		wpos -= Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_external_corner_tile_id(Vector2i(-1,-1)))
	for wpos in external_corner_ne:
		wpos -= Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_external_corner_tile_id(Vector2i(1,-1)))
	for wpos in external_corner_sw:
		wpos += Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_external_corner_tile_id(Vector2i(-1,1)))
	for wpos in external_corner_se:
		wpos += Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_external_corner_tile_id(Vector2i(1,1)))
		
	# Блок отрисовки внутренних углов
	for wpos in internal_corner_nw:
		wpos -= Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_internal_corner_tile_id(Vector2i(-1,-1)))
	for wpos in internal_corner_ne:
		wpos -= Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_internal_corner_tile_id(Vector2i(1,-1)))
	for wpos in internal_corner_sw:
		wpos += Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_internal_corner_tile_id(Vector2i(-1,1)))
	for wpos in internal_corner_se:
		wpos += Vector2i(0,1)
		tilemap.set_cell(0, wpos, 0, get_extra_internal_corner_tile_id(Vector2i(1,1)))
	

#================================================================
# Вспомогательные методы для выбора тайла
#================================================================
func get_wall_tile_id(dir: Vector2i) -> Vector2i:
	if dir == Vector2i(-1, 0): return Vector2i(4, 5)
	if dir == Vector2i(1,  0): return Vector2i(7, 5)
	if dir == Vector2i(0, -1): return Vector2i(6, 7)
	if dir == Vector2i(0,  1): return Vector2i(5, 6)
	if dir == Vector2i(-1,-1): return Vector2i(4, 0)
	if dir == Vector2i( 1,-1): return Vector2i(6, 0)
	if dir == Vector2i(-1, 1): return Vector2i(4, 2)
	if dir == Vector2i( 1, 1): return Vector2i(6, 2)
	return Vector2i(5, 7)

func get_internal_corner_tile_id(diag: Vector2i) -> Vector2i:
	# вставь тут координаты тайлов для переходных углов
	if diag == Vector2i(-1,-1): return Vector2i(6, 7) # Правый верхний
	if diag == Vector2i( 1,-1): return Vector2i(6, 7) # Левый верхний
	if diag == Vector2i(-1, 1): return Vector2i(5, 1) # Правый нижний
	if diag == Vector2i( 1, 1): return Vector2i(4, 1) # Левый нижний
	return Vector2i(5, 7)
	
func get_external_corner_tile_id(diag: Vector2i) -> Vector2i:
	# Внешние угловые тайлы
	if diag == Vector2i(-1,-1): return Vector2i(4, 5)  # Левый верхний внешний угол
	if diag == Vector2i( 1,-1): return Vector2i(7, 5)  # Правый верхний внешний угол
	if diag == Vector2i(-1, 1): return Vector2i(4, 6)  # Левый нижний внешний угол
	if diag == Vector2i( 1, 1): return Vector2i(7, 6)  # Правый нижний внешний угол
	return Vector2i(5, 7)  # Запасной вариант
	
func get_extra_wall_tile_id(dir: Vector2i) -> Vector2i:
	if dir == Vector2i(0, -1): return Vector2i(6, 6)
	if dir == Vector2i(0,  1): return Vector2i(6, 0)
	return Vector2i(5, 7)
	
func get_extra_internal_corner_tile_id(diag: Vector2i) -> Vector2i:
	# вставь тут координаты тайлов для переходных углов
	if diag == Vector2i(-1,-1): return Vector2i(5, 0) # Правый верхний
	if diag == Vector2i( 1,-1): return Vector2i(4, 0) # Левый верхний
	if diag == Vector2i(-1, 1): return Vector2i(6, 5) # Правый нижний
	if diag == Vector2i( 1, 1): return Vector2i(5, 5) # Левый нижний
	return Vector2i(5, 7)
	
func get_extra_external_corner_tile_id(diag: Vector2i) -> Vector2i:
	# Внешние угловые тайлы
	if diag == Vector2i(-1,-1): return Vector2i(4, 4)  # Левый верхний внешний угол
	if diag == Vector2i( 1,-1): return Vector2i(7, 4)  # Правый верхний внешний угол
	if diag == Vector2i(-1, 1): return Vector2i(4, 2)  # Левый нижний внешний угол
	if diag == Vector2i( 1, 1): return Vector2i(5, 2)  # Правый нижний внешний угол
	return Vector2i(5, 7)  # Запасной вариант
