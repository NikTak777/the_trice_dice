extends CharacterBody2D

const SPEED = 250.0

func _ready():
	position = Vector2.ZERO # Устанавливает начальную позицию на (0, 0)

func get_movement_direction():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return input_direction
	

func _process(delta):
	var diretion = get_movement_direction()
	
	velocity = diretion * SPEED
	
	move_and_slide()
