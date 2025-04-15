extends "res://scr/Entities/Enemies/BaseEnemy/base_enemy.gd"

@export var BULLET_SCENE = preload("res://scr/Objects/EnemyBullet/EnemyBullet.tscn")
@export var attack_interval: float = 1.0   # Интервал атаки
@export var projectile_speed: float = 300.0

var attack_timer: Timer
var player_in_range: bool = false
var room_active: bool = false  # Флаг, показывающий, что игрок находится в той же комнате, что и враг
@export var active: bool = false

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
	# Дополнительная проверка на случай, если по какой-то причине таймер сработал, а игрок уже не в зоне.
	if not player_in_range or not room_active:
		return
	
	# Создаем снаряд
	var projectile = BULLET_SCENE.instantiate()
	projectile.position = global_position
	
	# Вычисляем направление на игрока
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var direction = (players[0].global_position - global_position).normalized()
		# Если метод set_direction реализован, используем его для установки направления и скорости
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction, projectile_speed)
		else:
			# Альтернативно можно присвоить направление напрямую, если переменная публичная
			projectile.direction = direction
	
	get_tree().current_scene.add_child(projectile)
