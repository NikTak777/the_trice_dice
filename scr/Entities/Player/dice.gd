extends CharacterBody2D

@onready var ability_manager = preload("res://scr/Utils/AbilityManager/ability_manager.gd").new()
@onready var ability_scene = preload("res://scr/UserInterface/AbilityTitle/AbilityTitle.tscn")
@onready var menu: Control  # Подключаем меню

# const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")
const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/PlayerHealthBar/PlayerHealthBar.tscn")
const INVENTORY_SCENE = preload("res://scr/Utils/Inventory/Inventory.tscn")
const BULLET_SCENE = preload("res://scr/Objects/Bullet/Bullet.tscn")

var max_hp = 100
var current_hp = 100
var hp_bar = null  # Здесь хранится ссылку на HealthBar

var speed = 100.0
var damage_bonus: float = 1.0

var armor_bonus: float = 1.0 # Бонус усиления брони (уменьшает урон)

var nearby_weapon = null   # Оружие, рядом с которым персонаж
var inventory = null
var ability_instance = null  # Экземпляр AbilityTitle
var ability_label = null

var is_inside_room: bool = false

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0
var knockback_duration = 0.4

var is_console_open: bool = false

func _ready():
	position = Vector2.ZERO  # Устанавливает начальную позицию на (0, 0)
	add_to_group("player")
	# spawn_health_bar()
	
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
	if Global.is_console_open:
		return
	
	# Проверка на нажатие кнопки подбора оружия
	if Input.is_action_just_pressed("pickup"):
		print("Кнопка подбора нажата!")
		if nearby_weapon:
			var weapon_instance = nearby_weapon
			inventory.pickup_weapon(weapon_instance)
			weapon_instance.equip()
			nearby_weapon = null
			
	if Input.is_action_pressed("shoot") and is_inside_room:
		if inventory.carried_weapon:
			var weapon = inventory.carried_weapon
			weapon.shoot(global_position, get_global_mouse_position())
	
	if Input.is_action_just_pressed("spawn_weapon"):
		print("Кнопка спавна оружия нажата!")
		var weapon_factory_scene = preload("res://scr/Utils/WeaponFactory/WeaponFactory.tscn")
		var weapon_factory = weapon_factory_scene.instantiate()
		add_child(weapon_factory)
		var new_weapon = weapon_factory.create_weapon("Automat")
		add_child(new_weapon)
		inventory.pickup_weapon(new_weapon)
		new_weapon.equip()
		nearby_weapon = null
	
	if Input.is_action_just_pressed("change_ability"):
		print("Кнопка смены способности нажата!")
		change_ability()

func _physics_process(delta):
	if Global.is_console_open:
		return
	
	# Отталкивание (если активно)
	if knockback_timer > 0.0:
		# Плавное замедление отлёта
		velocity = knockback_velocity
		knockback_timer -= delta
		# Можно плавно уменьшать силу:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000 * delta)
	else:
		# Обычное движение
		var direction = get_movement_direction()
		velocity = direction * speed
	
	move_and_slide()


func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	menu.visible = !menu.visible
	
func spawn_health_bar():
	hp_bar = HEALTHBAR_SCENE.instantiate()  # Создаём экземпляр HealthBar
	add_child(hp_bar)  # Добавляем его как дочерний узел
	hp_bar.position = Vector2(-110, 100)  # Смещаем немного вверх
	hp_bar.set_max_hp(max_hp) # Новая строка

func take_damage(amount: int, source_position: Vector2 = global_position):
	
	current_hp -= amount * armor_bonus
	current_hp = max(current_hp, 0)
	hp_bar.set_hp(current_hp)  # Обновляем шкалу HP
	
	change_ability() # Смена способности при получении урона
	
	apply_knockback(source_position)
	
	if current_hp < 2:
		die()
		
func apply_knockback(from_position: Vector2):
	var direction = (global_position - from_position).normalized()
	var knockback_force = 400.0
	
	knockback_velocity = direction * knockback_force
	knockback_timer = knockback_duration
	
	# Вращаем игрока (только визуально, sprite)
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		var tween = create_tween()
		
		tween.tween_property(sprite, "rotation", sprite.rotation + deg_to_rad(360 * 2), knockback_duration)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Возврат в исходное состояние в конце
		tween.tween_property(sprite, "rotation", 0.0, 0.0).set_delay(knockback_duration)

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
