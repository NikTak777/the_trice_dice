# game_timer.gd
extends Node

var game_time: float = 0.0
var timer_running: bool = false

func _process(delta):
	if timer_running:
		game_time += delta

func start_timer():
	game_time = 0
	timer_running = true

func stop_timer():
	timer_running = false
	return game_time
	
func get_time():
	return game_time
