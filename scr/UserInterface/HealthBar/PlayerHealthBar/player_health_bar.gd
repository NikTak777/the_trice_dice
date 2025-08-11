extends Control

@onready var green_bar = $GreenBar
@onready var white_bar = $WhiteBar
var tween: Tween

var base_width: float = 500.0

func _ready():
	tween = create_tween()
	tween.set_loops(0)  # Один раз

func set_max_hp(value: int):
	green_bar.max_value = value
	white_bar.max_value = value
	
	var target_width = base_width * (value / 100.0) # Вычисляем новую ширину на основе максимального HP
	
	# Анимируем ширину обоих баров
	var size_tween = create_tween()
	size_tween.tween_property(green_bar, "custom_minimum_size", Vector2(target_width, green_bar.size.y), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	size_tween.tween_property(white_bar, "custom_minimum_size", Vector2(target_width, white_bar.size.y), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func set_hp(value: int):
	value = clamp(value, 0, green_bar.max_value)

	green_bar.value = value  # мгновенно обновляем основную шкалу

	# Анимация белой полоски через tween
	tween.kill()
	tween = create_tween()
	tween.tween_property(white_bar, "value", value, 0.3).set_delay(0.25)
	
	update_color()
	
func update_color():
	var fill_style = green_bar.get_theme_stylebox("fill").duplicate()
	var hp_percent = float(green_bar.value) / float(green_bar.max_value) * 100.0

	if hp_percent > 50:
		fill_style.bg_color = Color(0, 1, 0)  # Зелёный
	elif hp_percent > 20:
		fill_style.bg_color = Color(1, 1, 0)  # Жёлтый
	else:
		fill_style.bg_color = Color(1, 0, 0)  # Красный

	green_bar.add_theme_stylebox_override("fill", fill_style)
