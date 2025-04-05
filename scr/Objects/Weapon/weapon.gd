extends Node2D

@export var weapon_name: String = "BaseWeapon"
@export var cooldown_time: float = 0.5  # Интервал между выстрелами
@export var damage: int = 10            # Урон оружия
@export var weapon_texture: Texture2D
@export var sprite_target_height: float = 100.0

var is_equipped: bool = false

var time_since_last_shot: float = 0.0

func _ready():
	if has_node("Sprite2D") and weapon_texture:
		var sprite = $Sprite2D
		sprite.texture = weapon_texture
		_scale_sprite_to_height(sprite, sprite_target_height)
		
		# Если оружие не экипировано, отключаем _process (необязательно)
		set_process(false)

# Функция для активации режима "оружие в руках"
func equip() -> void:
	is_equipped = true
	set_process(true)

# Функция для деактивации режима "оружие в руках" (выбрасывание оружия)
func unequip() -> void:
	is_equipped = false
	set_process(false)

# Если нужно, можно сделать _process для обновления таймера, даже если оружие находится в инвентаре
func _process(delta: float) -> void:
	time_since_last_shot += delta
	if is_equipped:
		_rotate_weapon_to_cursor()
	
# Функция для расчета угла между оружием и курсором
func _rotate_weapon_to_cursor() -> void:
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - global_position
	var angle = direction.angle()
	$Sprite2D.rotation = angle

func can_shoot() -> bool:
	return time_since_last_shot >= cooldown_time

# Функция для стрельбы (создаёт пулю, сбрасывает таймер)
# Здесь мы принимаем позицию выстрела и целевую точку
func shoot(origin: Vector2, target: Vector2) -> void:
	if not can_shoot():
		print("Weapon", weapon_name, "on cooldown, wait:", cooldown_time - time_since_last_shot)
		return

	# Создаем пулю (предполагается, что BULLET_SCENE уже загружена, либо передается как параметр)
	var bullet_scene = preload("res://scr/Objects/Bullet/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = origin
	bullet.direction = (target - origin).normalized()

	# Добавляем пулю в игровую сцену (предполагается, что это корень)
	get_tree().current_scene.add_child(bullet)

	# Сбрасываем таймер
	time_since_last_shot = 0.0

	print("Weapon", weapon_name, "shot!")
	
func _scale_sprite_to_height(sprite: Sprite2D, target_height: float) -> void:
	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		if texture_size.y != 0:
			var scale = target_height / texture_size.y
			sprite.scale = Vector2(scale, scale)

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):	
		body.nearby_weapon = self
		print("Оружие обнаружено: ", weapon_name)
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.nearby_weapon == self:
			body.nearby_weapon = null
			print("Оружие покинуло зону: ", weapon_name)
