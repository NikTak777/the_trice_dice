extends Node

class_name DamageDealer

@export var damage_amount: int = 10
@export var damage_interval: float = 0.5

var area: Area2D
var timer: Timer

var player = null
var is_player_in_area = false
var damage_callback: Callable

func setup(area_node: Area2D, timer_node: Timer):
	area = area_node
	timer = timer_node

	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		is_player_in_area = true
		timer.start(1.0)

func _on_body_exited(body):
	if body == player:
		is_player_in_area = false
		player = null
		timer.stop()

func _on_timer_timeout():
	if is_player_in_area and player != null:
		if player.has_method("take_damage"):
			player.take_damage(damage_amount, get_parent().global_position)
		timer.start(damage_interval)

func set_damage_callback(cb: Callable):
	damage_callback = cb
