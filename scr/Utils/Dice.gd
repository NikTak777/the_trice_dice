extends CharacterBody2D

@export var pickup_radius: float = 50.0 # Радиус, в котором игрок может подбирать оружие
var current_weapon: Weapon = null # Переменная для хранения текущего оружия игрока

# Обрабатываем нажатия клавиш каждый кадр
func _process(delta):
    if Input.is_action_just_pressed("pickup_weapon"): # Проверяем, нажата ли кнопка подбора оружия
        try_pickup_weapon() # Пытаемся подобрать оружие

# Функция поиска и подбора ближайшего оружия
func try_pickup_weapon():
    var nearby_weapons = get_tree().get_nodes_in_group("weapons") # Получаем все оружия в группе "weapons"
    var closest_weapon: Weapon = null # Переменная для хранения ближайшего оружия
    var min_distance = pickup_radius # Минимальная дистанция до оружия

    for weapon in nearby_weapons:
        var distance = global_position.distance_to(weapon.global_position) # Рассчитываем расстояние до оружия
        if distance < min_distance: # Если оружие ближе, чем текущее минимальное расстояние
            closest_weapon = weapon # Запоминаем это оружие
            min_distance = distance # Обновляем минимальное расстояние

    if closest_weapon:
        pickup_weapon(closest_weapon) # Если найдено оружие в радиусе, подбираем его

# Функция подбора оружия
func pickup_weapon(new_weapon: Weapon):
    if current_weapon:
        drop_weapon() # Если у игрока уже есть оружие, выбрасываем старое

    current_weapon = new_weapon # Обновляем текущее оружие
    current_weapon.get_parent().remove_child(current_weapon) # Убираем оружие из текущей сцены
    add_child(current_weapon) # Добавляем оружие как дочерний объект игрока
    current_weapon.global_position = global_position # Перемещаем оружие к игроку
    new_weapon.pickup() # Вызываем функцию подбора оружия

# Функция выброса текущего оружия
func drop_weapon():
    if current_weapon:
        remove_child(current_weapon) # Удаляем оружие из игрока
        get_parent().add_child(current_weapon) # Добавляем оружие обратно в игровую сцену
        current_weapon.global_position = global_position # Оружие появляется в текущем месте игрока
        current_weapon = null # Обнуляем текущее оружие
