extends CharacterBody2D

@onready var menu = $"../CanvasLayer/MainMenu"  # Подключаем меню

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")  # Загружаем сцену заранее
const INVENTORY_SCENE = preload("res://scr/Utils/Inventory/Inventory.tscn")
const BULLET_SCENE = preload("res://scr/Objects/Bullet/Bullet.tscn")
const SPEED = 100.0

var max_hp = 100
var current_hp = 100
var hp_bar = null  # Здесь будем хранить ссылку на HealthBar

var nearby_weapon = null   # Оружие, рядом с которым персонаж
var inventory = null

func _ready():
	position = Vector2.ZERO  # Устанавливает начальную позицию на (0, 0)
	add_to_group("player")
	spawn_health_bar()
	
	# Создаем инвентарь и добавляем его в качестве дочернего узла
	inventory = INVENTORY_SCENE.instantiate()
	add_child(inventory)
	inventory.position = Vector2(10, 0)

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
		if nearby_weapon:
			inventory.pickup_weapon(nearby_weapon)
			nearby_weapon = null
			
	if Input.is_action_just_pressed("shoot"):
		if inventory.carried_weapon:
			shoot()
			move_and_slide()

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
	
func shoot():
	var bullet = BULLET_SCENE.instantiate()
	bullet.global_position = global_position  # Пуля вылетает из персонажа
	
	var mouse_pos = get_global_mouse_position()
	bullet.direction = (mouse_pos - global_position).normalized() # Вычисление направления от персонажа к курсору
	
	get_parent().add_child(bullet) # Добавление пули в сцену
