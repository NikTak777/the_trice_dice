extends Control

@onready var bar: ProgressBar = $ProgressBar  # Получаем ProgressBar

var max_hp: int = 100
var current_hp: int = 100

func _ready():
	bar.max_value = max_hp
	bar.value = current_hp
	update_color()

func set_hp(hp: int):
	current_hp = clamp(hp, 0, max_hp)  # Ограничиваем от 0 до max_hp
	bar.value = current_hp
	update_color()

func update_color():
	var fill_style = bar.get_theme_stylebox("fill").duplicate()
	if current_hp > 50:
		fill_style.bg_color = Color(0, 1, 0)  # Зелёный
	elif current_hp > 20:
		fill_style.bg_color = Color(1, 1, 0)  # Жёлтый
	else:
		fill_style.bg_color = Color(1, 0, 0)  # Красный
	bar.add_theme_stylebox_override("fill", fill_style)
