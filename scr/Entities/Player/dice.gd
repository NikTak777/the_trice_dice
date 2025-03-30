extends CharacterBody2D

@onready var menu = $"../CanvasLayer/MainMenu" # Подключаем меню

const SPEED = 100.0

func _ready():
	position = Vector2.ZERO # Устанавливает начальную позицию на (0, 0)

func get_movement_direction():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction
	
func _process(delta):
	if !get_tree().paused:
		var direction = get_movement_direction()
		velocity = direction * SPEED
		move_and_slide()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	menu.visible = !menu.visible
