extends CharacterBody2D

@onready var menu = $"../CanvasLayer/MainMenu" # Подключаем меню

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")  # Загружаем сцену заранее

const SPEED = 100.0

var max_hp = 100
var current_hp = 100
var hp_bar = null  # Здесь будем хранить ссылку на HealthBar

func _ready():
	position = Vector2.ZERO # Устанавливает начальную позицию на (0, 0)
	spawn_health_bar()

func get_movement_direction():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction
	
func _process(delta):
	if !get_tree().paused:
		var direction = get_movement_direction()
		velocity = direction * SPEED
		move_and_slide()
	if Input.is_action_just_pressed("damage"):
		print("Take damage!")
		take_damage(10)

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	menu.visible = !menu.visible
	

func spawn_health_bar():
	hp_bar = HEALTHBAR_SCENE.instantiate()  # Создаём экземпляр HealthBar
	add_child(hp_bar)  # Добавляем его как дочерний узел
	hp_bar.position = Vector2(-110, 100)  # Смещаем немного вверх

func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(current_hp, 0)
	hp_bar.set_hp(current_hp)  # Обновляем шкалу HP

	if current_hp == 0:
		die()

func die():
	queue_free()  # Удаляем персонажа
