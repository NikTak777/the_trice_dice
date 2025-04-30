extends Node

@export var speed: float = 40.0
@export var separation_strength: float = 200.0
@export var stop_distance: float = 80.0  # минимальная дистанция до игрока

@onready var move_area = get_parent().get_node("MovementArea")
@onready var sep_area = get_parent().get_node("SeparationArea")

var target: CharacterBody2D = null
var enemy_body: CharacterBody2D = null
var player_in_range: bool = false
var nearby_enemies: Array = []

func _ready():
	enemy_body = get_parent()
	
	# Сигналы от зоны стрельбы
	move_area.connect("body_entered", _on_movement_area_body_entered)
	move_area.connect("body_exited", _on_movement_area_body_exited)

	# Сигналы от зоны отталкивания
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
	if not target or not enemy_body or not enemy_body.room_active:
		enemy_body.velocity = Vector2.ZERO
		enemy_body.move_and_slide()
		return

	var velocity = Vector2.ZERO
	var distance_to_player = enemy_body.global_position.distance_to(target.global_position)

	# Двигаемся к игроку, если он вне зоны атаки, но не ближе чем stop_distance
	if not player_in_range and distance_to_player > stop_distance:
		var direction = (target.global_position - enemy_body.global_position).normalized()
		velocity = direction * speed
	
	# Добавляем репульсию от других врагов
	var repulsion = Vector2.ZERO
	for e in nearby_enemies:
		var diff = enemy_body.global_position - e.global_position
		var d = diff.length()
		if d > 0:
			repulsion += diff.normalized() * (separation_strength / d)

	enemy_body.velocity = velocity + repulsion
	enemy_body.move_and_slide()
