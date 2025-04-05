extends CharacterBody2D

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")
const DAMAGE_POPUP_SCENE = preload("res://scr/FX/DamagePopup/DamagePopup.tscn")

var max_hp: int = 100
var current_hp: int = 100
var hp_bar = null  # Здесь будем хранить ссылку на HealthBar

func _ready() -> void:
	add_to_group("enemy")
	position = Vector2.ZERO  # Устанавливает начальную позицию на (0, 0)
	spawn_health_bar()
	pass

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
