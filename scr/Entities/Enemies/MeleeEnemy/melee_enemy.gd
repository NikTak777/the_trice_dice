extends "res://scr/Entities/Enemies/BaseEnemy/base_enemy.gd"

@export var damage_amount: int = 10
@export var damage_interval: float = 0.5
@export var active: bool = false
@export var room_active: bool = false

@onready var damage_dealer := DamageDealer.new()
@onready var damage_area := $Area2D
@onready var damage_timer := $Timer

func _ready() -> void:
	super._ready()
	add_child(damage_dealer)
	damage_dealer.damage_amount = damage_amount
	damage_dealer.damage_interval = damage_interval
	damage_dealer.setup(damage_area, damage_timer)
	damage_dealer.set_damage_callback(Callable(self, "_on_damage_dealt"))

func _on_damage_dealt(amount: int):
	spawn_damage_popup(amount)
