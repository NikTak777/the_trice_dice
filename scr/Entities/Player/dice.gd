extends CharacterBody2D

@onready var menu = $"../CanvasLayer/MainMenu"  # Подключаем меню

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")  # Загружаем сцену заранее

const SPEED = 100.0

var max_hp = 100
var current_hp = 100
var hp_bar = null  # Здесь будем хранить ссылку на HealthBar

# Новые переменные для работы с оружием
var carried_weapon = null  # Оружие, которое подобрали
var nearby_weapon = null   # Оружие, рядом с которым персонаж

func _ready():
	position = Vector2.ZERO  # Устанавливает начальную позицию на (0, 0)
	add_to_group("player")
	spawn_health_bar()
	
	# Создаем слот для оружия, куда оно будет прикреплено
	var weapon_slot = Node2D.new()
	weapon_slot.name = "WeaponSlot"
	add_child(weapon_slot)
	weapon_slot.position = Vector2(10, 0)  # Смещение относительно персонажа (настройте по необходимости)

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
	
	# Проверка на нажатие кнопки подбора оружия
	if Input.is_action_just_pressed("pickup"):
		print("Кнопка подбора нажата!")
		if nearby_weapon and carried_weapon == null:
			print("Оружие рядом!")
			pickup_weapon(nearby_weapon)

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
	
# Функция подбора оружия
func pickup_weapon(weapon):
	carried_weapon = weapon
	# Переносим оружие в слот персонажа
	var slot = get_node("WeaponSlot")
	weapon.get_parent().remove_child(weapon)
	weapon.scale = Vector2(1.5, 1.5)
	slot.add_child(weapon)
	weapon.position = Vector2.ZERO  # Сбрасываем позицию относительно слота
	
	# Отключаем столкновения оружия, если они больше не нужны
	if weapon.has_node("Area2D"):
		weapon.get_node("Area2D").monitoring = false
	
	print("Подобрано оружие: ", weapon.weapon_name)
	# После подбора очищаем переменную nearby_weapon, чтобы не подбирать его повторно
	nearby_weapon = null
