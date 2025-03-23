extends Area2D

class_name Weapon

# Сигнал, который будет отправляться при подборе оружия
signal picked_up(weapon)

# Функция вызывается при создании объекта
func _ready():
    add_to_group("weapons") # Добавляем оружие в группу "weapons" для удобного поиска

# Функция, которая вызывается, когда оружие подбирается игроком
func pickup():
    picked_up.emit(self) # Отправляем сигнал, что оружие было подобрано
