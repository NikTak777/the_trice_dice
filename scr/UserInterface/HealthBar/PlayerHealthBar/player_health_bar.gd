extends Control

@onready var green_bar = $GreenBar
@onready var white_bar = $WhiteBar
var tween: Tween

var base_width: float = 350.0

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
