extends CharacterBody2D

var speed: float = 200.0  # заменяем константу на переменную, чтобы можно было изменять её значение
var direction: Vector2 = Vector2.ZERO
var damage: int = 10

func _ready():
	rotation = direction.angle() + deg_to_rad(90)

func set_direction(new_direction: Vector2, new_speed: float) -> void:
	direction = new_direction
	speed = new_speed
	# Можно обновить rotation после установки нового направления:
	rotation = direction.angle() + deg_to_rad(90)

func _physics_process(delta: float) -> void:
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage, global_position)
		else:
			var fx_scene = preload("res://scr/FX/WallHitEffect/WallHitEffect.tscn")
			var fx = fx_scene.instantiate()
			fx.global_position = position + direction * 5
			get_tree().current_scene.add_child(fx)
		queue_free()
	# Если столкновения не было, перемещение уже выполнено move_and_collide
