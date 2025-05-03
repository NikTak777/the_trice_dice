extends Node

@export var speed: float = 40.0
@export var stop_distance: float = 25.0  # минимальная дистанция до игрока
@export var separation_radius: float = 32.0     # радиус зоны SeparationArea
@export var separation_strength: float = 200.0  # сила отталкивания

@onready var move_area = get_parent().get_node("MovementArea")
@onready var sep_area = get_parent().get_node("SeparationArea")

var target: CharacterBody2D = null
var enemy_body: CharacterBody2D = null
var player_in_range: bool = false
var nearby_enemies := []

func _ready():
	enemy_body = get_parent()
	
	# сигналы остановки/старта
	move_area.connect("body_entered", _on_movement_area_body_entered)
	move_area.connect("body_exited", _on_movement_area_body_exited)
	# сигналы separation
	sep_area.connect("body_entered", _on_separation_area_body_entered)
	sep_area.connect("body_exited", _on_separation_area_body_exited)

func _on_movement_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_movement_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		
func _on_separation_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body != enemy_body:
		nearby_enemies.append(body)

func _on_separation_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		nearby_enemies.erase(body)

func _process(delta):
	if not enemy_body or not target:
		return
	
	# 1) Если враг не «активен» — не двигаем
	if not enemy_body.room_active:
		enemy_body.velocity = Vector2.ZERO
		enemy_body.move_and_slide()
		return

	# 2) Дистанция до игрока
	var dist = enemy_body.global_position.distance_to(target.global_position)
	var base_velocity = Vector2.ZERO

	# 2a) если зашёл в MovementArea и близко — стоим
	if not player_in_range or dist <= stop_distance:
	# Для хардкора
	# if player_in_range and dist <= stop_distance:
		base_velocity = Vector2.ZERO
	else:
		# идём на игрока
		var dir = (target.global_position - enemy_body.global_position).normalized()
		base_velocity = dir * speed

	# 3) Считаем репульсию от соседей
	var repulsion = Vector2.ZERO
	for e in nearby_enemies:
		var diff = enemy_body.global_position - e.global_position
		var d = diff.length()
		if d > 0:
			# сила обратно пропорциональна дистанции
			repulsion += diff.normalized() * (separation_strength / d)

	# Итоговая скорость
	enemy_body.velocity = base_velocity + repulsion
	enemy_body.move_and_slide()
