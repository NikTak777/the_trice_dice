extends Node2D

@onready var label: Label = $Label

func set_mana(current: int, max: int) -> void:
	label.text = "Mana: %d / %d" % [current, max]
