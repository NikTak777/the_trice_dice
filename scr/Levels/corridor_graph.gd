class_name CorridorGraph

extends Node

var corridors := []
var room_exit_dirs := {}

func build_corridor_graph(root_node) -> void:
	var rooms = []
	for leaf in root_node.get_leaves():
		rooms.append(leaf.get_center())

	corridors.clear()
	room_exit_dirs.clear()

	var visited = [rooms[0]]
	var unvisited = rooms.duplicate()
	unvisited.erase(rooms[0])
	
	while unvisited.size() > 0:
		var min_dist = INF
		var min_pair = null
		for v in visited:
			for u in unvisited:
				var dist = v.distance_squared_to(u)
				if dist < min_dist:
					min_dist = dist
					min_pair = [v, u]
		if min_pair != null:
			add_corridor_unique(min_pair[0], min_pair[1], root_node)
			visited.append(min_pair[1])
			unvisited.erase(min_pair[1])

func add_corridor_unique(a: Vector2i, b: Vector2i, root_node) -> void:
	var key = [a, b]
	if vector2i_less(b, a):
		key = [b, a]

	for c in corridors:
		if c[0] == key[0] and c[1] == key[1]:
			return

	corridors.append(key)

	var rooms = root_node.get_leaves()
	var a_idx = get_room_index_by_center(a, rooms)
	var b_idx = get_room_index_by_center(b, rooms)

	if a_idx != -1 and b_idx != -1:
		var dir_ab = (b - a).sign()
		var dir_ba = (a - b).sign()

		if not room_exit_dirs.has(a_idx + 1):
			room_exit_dirs[a_idx + 1] = []
		room_exit_dirs[a_idx + 1].append(dir_ab)

		if not room_exit_dirs.has(b_idx + 1):
			room_exit_dirs[b_idx + 1] = []
		room_exit_dirs[b_idx + 1].append(dir_ba)

func get_room_index_by_center(center: Vector2i, rooms: Array) -> int:
	for i in range(rooms.size()):
		if Vector2i(rooms[i].get_center()) == center:
			return i
	return -1
	
func vector2i_less(a: Vector2i, b: Vector2i) -> bool:
	if a.x < b.x:
		return true
	elif a.x > b.x:
		return false
	else:
		return a.y < b.y
