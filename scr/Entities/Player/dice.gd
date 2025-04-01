extends CharacterBody2D

@onready var menu = $"../CanvasLayer/MainMenu"  # Подключаем меню

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")  # Загружаем сцену заранее
const WEAPON_SCENE = preload("res://scr/Objects/pick_up_weapon/weapon.tscn")  # Путь к сцене оружия

const SPEED = 100.0
const PICKUP_DISTANCE = 20  # Расстояние, на котором можно подобрать оружие

var max_hp = 100
var current_hp = 100
var hp_bar = null  # Здесь будем хранить ссылку на HealthBar
var weapon: Node2D = null  # Храним ссылку на оружие

func _ready():
	position = Vector2.ZERO  # Устанавливает начальную позицию на (0, 0)
	spawn_health_bar()
	spawn_weapon()  # Спавним оружие на фиксированном месте

	print("Weapon spawned at position: ", weapon.position)  # Лог для проверки

func get_movement_direction():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction
	
func _process(delta):
	if !get_tree().paused:
		var direction = get_movement_direction()
		velocity = direction * SPEED
		move_and_slide()

	# Проверяем, что персонаж рядом с оружием и нажата клавиша "T" для подбора
	if weapon and is_near_weapon() and Input.is_action_just_pressed("pick_up_weapon"):
		collect_weapon()

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

# Функция для спавна оружия на фиксированном месте
func spawn_weapon():
	weapon = WEAPON_SCENE.instantiate()  # Создаём экземпляр оружия
	get_parent().add_child(weapon)  # Добавляем оружие на тот же уровень, что и персонаж
	weapon.position = position + Vector2(130, 100)  # Размещаем оружие
	weapon.scale = Vector2(0.3, 0.3)  # Уменьшаем оружие в 2 раза
	print("Weapon position: ", weapon.position)  # Лог для проверки

# Проверка, находится ли персонаж рядом с оружием
func is_near_weapon() -> bool:
	return position.distance_to(weapon.position) < PICKUP_DISTANCE

# Функция для подбора оружия
func collect_weapon():
	print("Weapon collected!")  # Выводим сообщение для теста
	weapon.queue_free()  # Удаляем оружие
	weapon = null  # Обнуляем ссылку на оружие
