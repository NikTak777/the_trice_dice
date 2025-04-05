extends CharacterBody2D

const SPEED = 100.0

var direction = Vector2.ZERO
var damage: int = 0

func _ready():
	rotation = direction.angle() + deg_to_rad(90)

func _process(delta: float) -> void:
	# Вычисляем движение за этот кадр.
	var motion = direction * SPEED * delta
	
	var collision = move_and_collide(motion)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider.is_in_group("enemy"):
			collider.take_damage(damage)
		else:
			# Эффект столкновения со стеной
			var fx_scene = preload("res://scr/FX/WallHitEffect/WallHitEffect.tscn")
			var fx = fx_scene.instantiate()
			fx.global_position = position + direction * 5
			get_tree().current_scene.add_child(fx)
		queue_free()
	else:
		position += motion
