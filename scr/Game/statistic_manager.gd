extends Node

var GameTimer = preload("res://scr/Game/game_timer.gd")

var game_timer: Node

func _ready():
	game_timer = GameTimer.new()
	add_child(game_timer)

func start_game():
	game_timer.start_timer()

func end_game(is_victory: bool):
	var elapsed = game_timer.stop_timer()
	Global.is_last_game_victory = is_victory
	Global.last_run_time = elapsed
	Global.last_game_difficulty = SettingsManager.get_current_difficulty()

	print("Victory:", is_victory, " Time:", elapsed)
