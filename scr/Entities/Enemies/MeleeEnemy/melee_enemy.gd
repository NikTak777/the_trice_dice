extends "res://scr/Entities/Enemies/BaseEnemy/base_enemy.gd"

@export var damage_amount: int = 10
@export var damage_interval: float = 0.5
@export var room_active: bool = false # Флаг, показывающий, что игрок находится в той же комнате, что и враг

@onready var damage_dealer := DamageDealer.new()
@onready var damage_area := $Area2D
@onready var damage_timer := $Timer

@onready var movement_script = $MeleeMovement

func _ready() -> void:
	super._ready()
	add_child(damage_dealer)
	damage_dealer.damage_amount = damage_amount
	damage_dealer.damage_interval = damage_interval
	damage_dealer.setup(damage_area, damage_timer)
	damage_dealer.set_damage_callback(Callable(self, "_on_damage_dealt"))
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		movement_script.target = players[0]

func _on_damage_dealt(amount: int):
	spawn_damage_popup(amount)
