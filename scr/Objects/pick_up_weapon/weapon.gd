extends Area2D

@export var weapon_name = "Weapon"  # Название оружия, можно использовать для дальнейших действий

# Сигнал, который будет срабатывать, когда персонаж столкнется с оружием
signal weapon_collected(weapon_name)

func _ready():
	# Инициализация
	pass

# Этот метод будет вызываться, когда персонаж столкнется с оружием
func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):  # Проверяем, если это персонаж
		emit_signal("weapon_collected", weapon_name)  # Посылаем сигнал, что оружие собрано
		queue_free()  # Удаляем оружие
