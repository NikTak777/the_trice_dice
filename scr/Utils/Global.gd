extends Node

var is_game_over: bool = false

var is_console_open: bool = false

var enemies_killed: int = 0

var last_run_time: float = 0.0 # Время нахождения в последней игре

var is_last_game_victory: bool = false # Статус последней игры (победа или проигрыш)

var last_game_difficulty: String = "" # Название сложности последней игры

var best_run_time: float = 0.0 
