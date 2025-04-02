extends Node2D

@export var weapon_name = "Weapon"

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):	
		body.nearby_weapon = self
		print("Оружие обнаружено: ", weapon_name)
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.nearby_weapon == self:
			body.nearby_weapon = null
			print("Оружие покинуло зону: ", weapon_name)
