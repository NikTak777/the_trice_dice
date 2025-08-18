extends Node

var master_volume: float = 1.0 # Уровень громкости
var fullscreen: bool = false # Статус полнокэранного режима
var difficulty: String = "Normal" # Режим сложности по умолчанию

var difficulties = ["Easy", "Normal", "Hard"] # Список режимов сложности
var current_difficulty: int = 1 # индекс текущей сложности в массиве difficulties

# Настройки разброса и скорострельность для каждой сложности
var boss_inaccuracy_settings = {
	"Easy": {"min_ang": 7.0, "max_ang": 10.0, "interval": 0.7},
	"Normal": {"min_ang": 3.0, "max_ang": 8.0, "interval": 0.5},
	"Hard": {"min_ang": 0.0, "max_ang": 0.0, "interval": 0.3}
}

func apply_settings():
	# Громкость
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	# Полноэкранный режим
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Смена сложности влево (уменьшение)
func decrease_difficulty():
	current_difficulty = (current_difficulty - 1 + difficulties.size()) % difficulties.size()
	difficulty = difficulties[current_difficulty]

# Смена сложности вправо (увеличение)
func increase_difficulty():
	current_difficulty = (current_difficulty + 1) % difficulties.size()
	difficulty = difficulties[current_difficulty]

# Получение текущей сложности
func get_current_difficulty() -> String:
	return difficulties[current_difficulty]
	
# Получение текущего значения разброса босса
func get_boss_inaccuracy() -> Dictionary:
	return boss_inaccuracy_settings[difficulty]
