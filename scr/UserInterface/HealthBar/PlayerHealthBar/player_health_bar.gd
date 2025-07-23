extends Control

@onready var green_bar = $GreenBar
@onready var white_bar = $WhiteBar
var tween: Tween

func _ready():
	tween = create_tween()
	tween.set_loops(0)  # Один раз

func set_max_hp(value: int):
	green_bar.max_value = value
	white_bar.max_value = value

func set_hp(value: int):
	value = clamp(value, 0, green_bar.max_value)

	green_bar.value = value  # мгновенно обновляем основную шкалу

	# Анимация белой полоски через tween
	tween.kill()
	tween = create_tween()
	tween.tween_property(white_bar, "value", value, 0.3).set_delay(0.25)
