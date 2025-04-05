extends Node2D

@onready var label: Label = $Label

var lifetime := 0.8
var float_speed := -30.0

func setup(damage_amount: int):
	label.text = "-" + str(damage_amount)
	label.modulate = Color(1, 0.1, 0.1)
	scale = Vector2(0.5, 0.5)

func _process(delta: float):
	position.y += float_speed * delta
	modulate.a -= delta / lifetime
	if modulate.a <= 0:
		queue_free()
