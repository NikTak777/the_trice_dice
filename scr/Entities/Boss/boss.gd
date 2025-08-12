extends CharacterBody2D

var max_hp: int = 1000
var current_hp: int = 0
var hp_bar = null
var room_active: bool = false
@onready var movement_script = $BossMovement

const HEALTHBAR_SCENE = preload("res://scr/UserInterface/HealthBar/HealthBar.tscn")
const DAMAGE_POPUP_SCENE = preload("res://scr/FX/DamagePopup/DamagePopup.tscn")


func _ready() -> void:
	add_to_group("boss")
	current_hp = max_hp
	spawn_health_bar()
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		movement_script.target = players[0]

func spawn_health_bar():
	hp_bar = HEALTHBAR_SCENE.instantiate()
	add_child(hp_bar)
	hp_bar.position = Vector2(-120, 210)
	hp_bar.scale = Vector2(1.0, 1.0)
	hp_bar.set_max_hp(max_hp)
	hp_bar.set_hp(current_hp)

func spawn_damage_popup(amount: int):
	var popup = DAMAGE_POPUP_SCENE.instantiate()
	add_child(popup)
	popup.global_position = global_position + Vector2(0, -10)
	popup.setup(amount, true)
	get_tree().current_scene.add_child(popup)

func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(current_hp, 0)
	hp_bar.set_hp(current_hp)
	spawn_damage_popup(amount)
	if current_hp == 0:
		die()

func die():
	var victory_node = Node.new()
	victory_node.set_script(preload("res://scr/Entities/Player/victory_player.gd"))
	victory_node.victory_scene = preload("res://scr/UserInterface/VictoryLabel/Victory.tscn")
	get_tree().get_root().add_child(victory_node)
	queue_free()
