extends Node

var current_value: int = 0
var min_value: int = 0
var max_value: int = 300 # Временно, пока не знаю сколько нужно будет
var bonus: int = 0

signal mana_changed(current_value: int, max_value: int)

func _ready():
	current_value = max_value
	emit_signal("mana_changed", current_value, max_value)
	print("Mana_points: ", current_value)

func change_value(delta: int) -> void:
	"""Изменяет количество маны на указанную величину
	Arg: delta - число очков, на которое изменяется мана (положительное или отрицательное))
	"""
	if can_change_value(delta):
		current_value = clamp(current_value + delta + bonus, min_value, max_value)
		emit_signal("mana_changed", current_value, max_value)
		print("Mana_points:", current_value)
	
func can_change_value(delta: int) -> bool:
	if not(-delta + bonus == 0 or (delta + bonus < 0 and current_value < -delta + bonus)):
		return true
	return false
	
func get_value() -> int:
	return current_value
