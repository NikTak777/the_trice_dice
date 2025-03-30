extends Node2D

func _physics_process(_delta):
	var parent = get_parent()
	
	if parent is CharacterBody2D:
		var sprite = parent.get_node("Sprite2D")
		if sprite and parent.velocity.x != 0:
			sprite.flip_h = parent.velocity.x < 0
