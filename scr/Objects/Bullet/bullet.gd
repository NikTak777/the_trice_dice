extends CharacterBody2D

const SPEED = 100.0

var direction = Vector2.ZERO

func _ready():
	rotation = direction.angle() + deg_to_rad(90)

func _process(delta: float) -> void:
	# Вычисляем движение за этот кадр.
	var motion = direction * SPEED * delta
	
	var collision = move_and_collide(motion)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider.is_in_group("enemy"):
			collider.queue_free()
		queue_free()
	else:
		position += motion
