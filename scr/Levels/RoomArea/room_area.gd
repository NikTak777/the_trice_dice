# RoomArea.gd
extends Area2D

@export var room_number: int = 0

signal player_entered_room(room_number)
signal player_exited_room(room_number)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
func _on_body_entered(body):
	# Предполагаем, что у игрока есть группа "player"
	if body.is_in_group("player"):
		emit_signal("player_entered_room", room_number)
		
func _on_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("player_exited_room", room_number)
