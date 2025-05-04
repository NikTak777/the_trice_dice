extends CharacterBody2D

@onready var menu = $"../CanvasLayer/InGameMenu"  # Подключаем меню
@onready var ability_manager = preload("res://scr/Utils/AbilityManager/ability_manager.gd").new()
@onready var ability_scene = preload("res://scr/UserInterface/AbilityTitle/AbilityTitle.tscn")

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")  # Загружаем сцену заранее
const INVENTORY_SCENE = preload("res://scr/Utils/Inventory/Inventory.tscn")
const BULLET_SCENE = preload("res://scr/Objects/Bullet/Bullet.tscn")


var max_hp = 100
var current_hp = 100
var hp_bar = null  # Здесь будем хранить ссылку на HealthBar

var speed = 100.0
var damage_bonus: float = 1.0

var nearby_weapon = null   # Оружие, рядом с которым персонаж
var inventory = null
var ability_instance = null  # Экземпляр AbilityTitle
var ability_label = null



func _ready():
	position = Vector2.ZERO  # Устанавливает начальную позицию на (0, 0)
	add_to_group("player")
	spawn_health_bar()
	
	# Создаем инвентарь и добавляем его в качестве дочернего узла
	inventory = INVENTORY_SCENE.instantiate()
	add_child(inventory)
	inventory.position = Vector2(10, 0)
	
	add_child(ability_manager)
	
	# Инстанцируем AbilityTitle и добавляем его в сцену
	ability_instance = ability_scene.instantiate()
	add_child(ability_instance)
	# Получаем ссылку на Label внутри AbilityTitle
	ability_label = ability_instance.get_node("Label") as Label

func get_movement_direction():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction
	
func _process(delta):
	if !get_tree().paused:
		var direction = get_movement_direction()
		velocity = direction * speed
		move_and_slide()
	
	# Проверка на нажатие кнопки подбора оружия
	if Input.is_action_just_pressed("pickup"):
		print("Кнопка подбора нажата!")
		if nearby_weapon:
			var weapon_instance = nearby_weapon
			inventory.pickup_weapon(weapon_instance)
			weapon_instance.equip()
			nearby_weapon = null
			
	if Input.is_action_pressed("shoot"):
		if inventory.carried_weapon:
			var weapon = inventory.carried_weapon
			weapon.shoot(global_position, get_global_mouse_position())

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	menu.visible = !menu.visible
	
func spawn_health_bar():
	hp_bar = HEALTHBAR_SCENE.instantiate()  # Создаём экземпляр HealthBar
	add_child(hp_bar)  # Добавляем его как дочерний узел
	hp_bar.position = Vector2(-110, 100)  # Смещаем немного вверх

func take_damage(amount: int):
	# Смена способности при получении урона:
	change_ability()
	
	current_hp -= amount
	current_hp = max(current_hp, 0)
	hp_bar.set_hp(current_hp)  # Обновляем шкалу HP
	
	if current_hp < 2:
		die()

func die():
	queue_free()  # удаляем игрока и всё привязанное

	# Создаём ноду с логикой смерти
	var death_node = Node.new()
	death_node.set_script(preload("res://scr/Entities/Player/death_player.gd"))
	death_node.game_over_scene = preload("res://scr/UserInterface/GameOverLabel/GameOver.tscn")
	get_tree().get_root().add_child(death_node)
	
func change_ability():
	var upgrade_message = ability_manager.change_ability(self)
	ability_label.text = upgrade_message
