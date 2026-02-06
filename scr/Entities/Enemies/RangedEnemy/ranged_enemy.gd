extends "res://scr/Entities/Enemies/BaseEnemy/base_enemy.gd"

@export var BULLET_SCENE = preload("res://scr/Objects/EnemyBullet/EnemyBullet.tscn")
@export var attack_interval: float = 1.0   # Интервал атаки
@export var projectile_speed: float = 300.0
@export var min_inaccuracy_angle_deg: float = 0.0 # Минимальный разброс в градусах
@export var max_inaccuracy_angle_deg: float = 0.0 # Максимальный разброс в градусах
@export var room_active: bool = false  # Флаг, показывающий, что игрок находится в той же комнате, что и враг

@onready var smart_bullet_direction = preload("res://scr/Utils/SmartBulletDirection/smart_bullet_direction.gd").new()

var attack_timer: Timer
var player_in_range: bool = false

@onready var movement_script = $RangedMovement

func _ready() -> void:
	super._ready()
	
	# Подключаем сигналы детектора (предполагается, что узел Area называется "DetectionArea")
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Создаем таймер атаки, но не запускаем его сразу
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = false
	attack_timer.autostart = false
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_attack"))
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		movement_script.target = players[0]
		
	var inaccuracy = SettingsManager.get_enemies_inaccuracy()
	min_inaccuracy_angle_deg = inaccuracy["min_ang"]
	max_inaccuracy_angle_deg = inaccuracy["max_ang"]

func _on_body_entered(body: Node) -> void:
	# Если в зону входит объект, принадлежащий группе "player", начинаем атаку
	if body.is_in_group("player"):
		player_in_range = true
		attack_timer.start()

func _on_body_exited(body: Node) -> void:
	# Когда игрок покидает зону, прекращаем атаку
	if body.is_in_group("player"):
		player_in_range = false
		attack_timer.stop()

func _attack():
	
	if not player_in_range or not room_active:
		return
	
	# Создаем снаряд
	var projectile = BULLET_SCENE.instantiate()
	projectile.position = global_position
	
	# Вычисляем направление на игрока
	var player = get_tree().get_first_node_in_group("player")
	var to_player = player.global_position - global_position
	
	if SettingsManager.get_current_difficulty() in ["Easy", "Normal"]:
		var direction = (to_player).normalized()
		projectile.set_direction(direction, projectile_speed)
	else:
		var aim_direction = smart_bullet_direction.get_bullet_direction(
			player, global_position, projectile_speed,
			min_inaccuracy_angle_deg, max_inaccuracy_angle_deg
		)
		projectile.set_direction(aim_direction, projectile_speed)
	
	get_tree().current_scene.add_child(projectile)
