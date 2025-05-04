extends CanvasLayer

@onready var label := $Label

func _ready():
	var settings = LabelSettings.new()
	settings.font_size = 32
	settings.shadow_color = Color.BLACK
	settings.shadow_offset = Vector2(2, 2)
	label.label_settings = settings
	label.position += Vector2(0.0, -100.0)
	label.modulate.a = 1.0  # Полностью видим

func show_hint(text: String, duration: float = 5.0) -> void:
	label.text = text
	label.visible = true
	label.modulate.a = 1.0  # Сброс прозрачности
	var tween = create_tween()
	tween.tween_interval(duration - 2.0)
	tween.tween_property(label, "modulate:a", 0.0, 2.0)
	await tween.finished
	label.visible = false
