extends Node2D

@export var duration = 0.3

func _ready():
	$Sprite2D.scale = Vector2(0.03, 0.03)
	await get_tree().create_timer(duration).timeout
	queue_free()
