extends CharacterBody2D

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")
const DAMAGE_POPUP_SCENE = preload("res://scr/FX/DamagePopup/DamagePopup.tscn")

@export var damage_amount: int = 10  # Наносимый урон
@export var damage_interval: float = 0.5  # Интервал между ударами (в секундах)

var max_hp: int = 100
var current_hp: int = 100
var hp_bar = null  # Здесь будем хранить ссылку на HealthBar

@onready var damage_area = $Area2D  # Ссылаемся на только что добавленный Area2D
@onready var damage_timer = Timer.new()  # Таймер для интервала между ударами

var is_player_in_area = false  # Флаг, показывающий, находится ли игрок в зоне
var player = null  # Ссылка на объект игрока

func _ready() -> void:
	add_to_group("enemy")
	position = Vector2.ZERO  # Устанавливает начальную позицию на (0, 0)
	spawn_health_bar()
	
	# Подключаем сигнал для начала атаки
	damage_area.connect("body_entered", Callable(self, "_on_body_entered"))
	# Подключаем сигнал для остановки атаки
	damage_area.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Настройка таймера
	damage_timer.one_shot = false
	damage_timer.autostart = false
	add_child(damage_timer)  # Добавляем таймер в дерево сцены

	# Подключаем сигнал таймера
	damage_timer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))

func _process(delta: float) -> void:
	pass
	
func spawn_health_bar():
	hp_bar = HEALTHBAR_SCENE.instantiate()  # Создаём экземпляр HealthBar
	add_child(hp_bar)  # Добавляем его как дочерний узел
	hp_bar.position = Vector2(-11, 20)  # Смещаем немного вверх
	hp_bar.scale = Vector2(0.1, 0.1)  # Смещаем немного вверх
	
func spawn_damage_popup(amount: int):
	var popup = DAMAGE_POPUP_SCENE.instantiate()
	add_child(popup) 
	popup.global_position = global_position + Vector2(0, -10)
	popup.setup(amount)
	get_tree().current_scene.add_child(popup)
	
func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(current_hp, 0)
	hp_bar.set_hp(current_hp)  # Обновляем шкалу HP
	spawn_damage_popup(amount)

	if current_hp == 0:
		die()

func die():
	queue_free()  # Удаляем персонажа

# Обработчик сигнала для начала нанесения урона
func _on_body_entered(body):
	if body.is_in_group("player"):  # Проверяем, что это главный герой
		print("Главный герой вошел в зону, начинаем наносить урон!")
		is_player_in_area = true  # Устанавливаем флаг, что игрок в зоне
		player = body  # Сохраняем ссылку на игрока
		# Запускаем таймер, который начнёт наносить урон после 1 секунды
		damage_timer.start(1.0)

# Обработчик сигнала для остановки урона
func _on_body_exited(body):
	if body.is_in_group("player"):  # Проверяем, что это главный герой
		print("Главный герой покинул зону, прекращаем наносить урон!")
		is_player_in_area = false  # Останавливаем нанесение урона
		damage_timer.stop()  # Останавливаем таймер

# Обработчик сигнала таймера для начала нанесения урона
func _on_damage_timer_timeout():
	if is_player_in_area and player != null:  # Если игрок все еще в зоне
		print("Наносим урон главному герою!")
		_damage_player(player)  # Наносим урон
		damage_timer.start(damage_interval)  # Повторяем через интервал

# Наносим урон главному герою
func _damage_player(player):
	if player.has_method("take_damage") and is_player_in_area:  # Наносим урон только если игрок в зоне
		print("Наносим урон главному герою!")
		player.take_damage(damage_amount)  # Наносим урон
		spawn_damage_popup(damage_amount)  # Показываем всплывающее уведомление о уроне
