extends Node2D

@export var BULLET_SCENE = preload("res://scr/Objects/EnemyBullet/EnemyBullet.tscn")

@export var attack_interval: float = 0.5  # Интервал атаки
@export var projectile_speed: float = 300.0
@export var min_inaccuracy_angle_deg: float = 3.0 # 7.0  # Минимальный разброс в градусах
@export var max_inaccuracy_angle_deg: float = 8.0 # 10.0  # Максимальный разброс в градусах

var attack_timer: Timer
var player_in_range: bool = false
@onready var attack_area = get_parent().get_node("MovementArea")

func _ready() -> void:
	
	# Подключаем сигналы детектора (предполагается, что узел Area называется "DetectionArea")
	attack_area.connect("body_entered", Callable(self, "_on_movement_area_body_entered"))
	attack_area.connect("body_exited", Callable(self, "_on_movement_area_body_exited"))
	
	# Создаем таймер атаки, но не запускаем его сразу
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = false
	attack_timer.autostart = false
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_attack"))
		
func _on_movement_area_body_entered(body: Node2D) -> void:
	# Если в зону входит объект, принадлежащий группе "player", начинаем атаку
	if body.is_in_group("player"):
		player_in_range = true
		attack_timer.start()

func _on_movement_area_body_exited(body: Node2D) -> void:
	# Когда игрок покидает зону, прекращаем атаку
	if body.is_in_group("player"):
		player_in_range = false
		attack_timer.stop()

func _attack():
	if not player_in_range or not get_parent().room_active:
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return

	var player = players[0]
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
	var offset_angle = get_angle_offset_relative_to_player(player, move_dir)
	aim_direction = aim_direction.rotated(offset_angle)

	# Создаём снаряд
	var projectile = BULLET_SCENE.instantiate()
	projectile.position = global_position

	if projectile.has_method("set_direction"):
		projectile.set_direction(aim_direction, projectile_speed)
	else:
		projectile.direction = aim_direction

	get_tree().current_scene.add_child(projectile)

# Умная функция для расчёта отклонения по направлению движения игрока
func get_angle_offset_relative_to_player(player: Node2D, move_dir: Vector2) -> float:
	if move_dir.length_squared() == 0: #игрок стоит
		return 0.0
		
	var to_player = (player.global_position - global_position).normalized()
	var player_movement = player.velocity.normalized()

	var cross := to_player.cross(player_movement)
	var angle_deg := randf_range(min_inaccuracy_angle_deg, max_inaccuracy_angle_deg)

	# Направление отклонения зависит от вращения
	if cross < 0:
		angle_deg = -angle_deg

	return deg_to_rad(angle_deg)
