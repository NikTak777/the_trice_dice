extends Node

var GameTimer = preload("res://scr/Game/game_timer.gd")

var game_timer: Node

var save_path := "user://stats.json"

var enemies_killed: int = 0
var last_run_time: float = 0.0 # Время нахождения в последней игре
var is_last_game_victory: bool = false # Статус последней игры (победа или проигрыш)
var last_game_difficulty: String = "" # Название сложности последней игры
var best_run_time: float = 0.0 

var stats := {
	"games": [], # Список всех игр
	"best_time": 0.0 # Лучшее время прохождения
}

func _ready():
	load_stats()
	
	game_timer = GameTimer.new()
	add_child(game_timer)

func start_game():
	game_timer.start_timer()

func end_game(is_victory: bool):
	var elapsed = game_timer.stop_timer()
	is_last_game_victory = is_victory
	last_run_time = elapsed
	last_game_difficulty = SettingsManager.get_current_difficulty()
	#if (last_run_time < best_run_time or best_run_time == 0.0) and is_victory == true:
		#Global.best_run_time = Global.last_run_time
	
	add_game(is_victory, last_run_time, last_game_difficulty)

	print("Victory:", is_victory, " Last time:", elapsed, " Best time: ", best_run_time)
	
# Добавить запись о новой игре
func add_game(is_victory: bool, elapsed: float, difficulty: String):
	var game_data = {
		"is_victory": is_victory,
		"time": elapsed,
		"difficulty": difficulty,
		"date": Time.get_datetime_string_from_system() # фиксируем дату
	}
	stats["games"].append(game_data)

	# обновляем лучший результат
	if is_victory:
		var best = get_best_time()
		if best == 0.0 or elapsed < best:
			stats["best_time"] = elapsed

	save_stats()
	
	update_local_stats()

# Сохранение в файл
func save_stats():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(stats, "\t")) # с табуляцией для удобства
		file.close()

# Загрузка из файла
func load_stats():
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if typeof(result) == TYPE_DICTIONARY:
		stats = result
	
	update_local_stats()

func update_local_stats():
	best_run_time = stats["best_time"]
	var last_game_info = get_last_games(1)[0]
	last_run_time = last_game_info["time"]
	is_last_game_victory = last_game_info["is_victory"]
	last_game_difficulty = last_game_info["difficulty"]

# Получить лучший результат
func get_best_time() -> float:
	return stats.get("best_time", 0.0)

# Получить последние N игр
func get_last_games(n: int = 5) -> Array:
	return stats["games"].slice(max(0, stats["games"].size() - n), stats["games"].size())
	
func has_any_game() -> bool:
	return stats["games"].size() > 0

func has_best_time() -> bool:
	return best_run_time > 0.0
