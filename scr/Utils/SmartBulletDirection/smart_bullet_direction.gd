extends Node

func get_bullet_direction(
	player: CharacterBody2D, 
	global_position: Vector2,
	projectile_speed: float,
	min_inaccuracy_angle_deg: float,
	max_inaccuracy_angle_deg: float
	) -> Vector2:
	var to_player = player.global_position - global_position

	# Получаем вектор скорости игрока
	var move_dir = player.get_movement_direction()
	var player_velocity = move_dir * player.speed

	# Время до столкновения пули с текущей позицией игрока
	var distance = to_player.length()
	var bullet_time = distance / projectile_speed

	# Предсказанная позиция игрока
	var predicted_position = player.global_position + player_velocity * bullet_time

	# Рассчёт финального направления с упреждением
	var aim_direction = (predicted_position - global_position).normalized()

	# Добавим умное отклонение
	var offset_angle = get_angle_offset_relative_to_player(
		player, move_dir, global_position,
		min_inaccuracy_angle_deg, max_inaccuracy_angle_deg)
	aim_direction = aim_direction.rotated(offset_angle)
	
	return aim_direction


# Умная функция для расчёта отклонения по направлению движения игрока
func get_angle_offset_relative_to_player(
	player: Node2D,
	move_dir: Vector2,
	global_position: Vector2,
	min_inaccuracy_angle_deg: float,
	max_inaccuracy_angle_deg: float
	) -> float:
	if move_dir.length_squared() == 0: # игрок стоит
		return 0.0
		
	var to_player = (player.global_position - global_position).normalized()
	var player_movement = player.velocity.normalized()

	var cross := to_player.cross(player_movement)
	var angle_deg := randf_range(min_inaccuracy_angle_deg, max_inaccuracy_angle_deg)

	# Направление отклонения зависит от вращения
	if cross < 0:
		angle_deg = -angle_deg

	return deg_to_rad(angle_deg)
