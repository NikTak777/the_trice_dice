extends CharacterBody2D

@export var max_hp: int = 100
var current_hp: int = 0
var hp_bar = null

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")
const DAMAGE_POPUP_SCENE = preload("res://scr/FX/DamagePopup/DamagePopup.tscn")

func _ready() -> void:
	add_to_group("enemy")
	current_hp = max_hp
	spawn_health_bar()

func spawn_health_bar():
	hp_bar = HEALTHBAR_SCENE.instantiate()
	add_child(hp_bar)
	hp_bar.position = Vector2(-11, 20)
	hp_bar.scale = Vector2(0.1, 0.1)

func spawn_damage_popup(amount: int):
	var popup = DAMAGE_POPUP_SCENE.instantiate()
	add_child(popup)
	popup.global_position = global_position + Vector2(0, -10)
	popup.setup(amount)
	get_tree().current_scene.add_child(popup)

func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(current_hp, 0)
	hp_bar.set_hp(current_hp)
	spawn_damage_popup(amount)
	if current_hp == 0:
		die()

func die():
	var scene = get_tree().get_current_scene()
	if scene.has_node("EnemyManager"):
		var manager = scene.get_node("EnemyManager")
		manager.enemy_died()
	else:
		print("EnemyManager не найден в current_scene!")
	queue_free()
