extends CanvasLayer

@onready var label := $Label
var tween: Tween = null  # Хранит текущий твин

func _ready():
	var settings = LabelSettings.new()
	settings.font_size = 32
	settings.shadow_color = Color.BLACK
	settings.shadow_offset = Vector2(2, 2)
	label.label_settings = settings
	label.position += Vector2(0.0, -100.0)
	label.modulate.a = 0.0  # Начинаем невидимыми
	# label.modulate.a = 1.0  # Полностью видим
	label.visible = false

func show_hint(text: String, duration: float = 5.0) -> void:
	if tween and tween.is_running():
		tween.kill()
	
	label.text = text
	label.visible = true
	label.modulate.a = 0.0  # Начинаем с полной прозрачности
	
	tween = create_tween()

	# --- Плавное появление (fade in) ---
	tween.tween_property(label, "modulate:a", 1.0, 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Ждём оставшееся время (минус появление и затухание)
	var hold_time = max(duration - 2.5, 0.0)
	if hold_time > 0.0:
		tween.tween_interval(hold_time)

	# --- Плавное исчезновение (fade out) ---
	tween.tween_property(label, "modulate:a", 0.0, 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.finished.connect(func():
		label.visible = false
	)
