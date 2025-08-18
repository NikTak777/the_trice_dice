extends Control

@onready var last_game_info: Label = $LastGameInfoContainer/LastGameInfoText

func _ready():
	# Подключение сигналов
	$VBoxContainer/Button.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/Button2.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/Button3.pressed.connect(_on_exit_button_pressed)
	
	update_statistic()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scr/Game/game.tscn")
	queue_free()

func _on_settings_button_pressed():
	var settings_scene = preload("res://scr/UserInterface/SettingsMenu/SettingsMenu.tscn").instantiate()
	get_tree().current_scene.add_child(settings_scene)

func _on_exit_button_pressed():
	get_tree().quit()
	
func update_statistic():
	if not StatisticManager.has_any_game():
		last_game_info.visible = false
		return
	
	# Создаём фон
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color("5a0000") if not StatisticManager.is_last_game_victory else Color("785e00")
	bg.corner_radius_top_left = 16
	bg.corner_radius_top_right = 16
	bg.corner_radius_bottom_right = 16
	bg.corner_radius_bottom_left = 16
	bg.corner_detail = 8
	bg.expand_margin_top = 26
	bg.expand_margin_bottom = 26
	bg.shadow_color = Color(0, 0, 0)
	bg.shadow_size = 4

	last_game_info.add_theme_stylebox_override("normal", bg)
	last_game_info.visible = true
	
	if not StatisticManager.is_last_game_victory:
		if StatisticManager.has_best_time():
			last_game_info.text = "Last game info:\nLose\nDifficulty: %s\nLast time: %.2fs\n--------------------------\nBest time: %.2fs" % [
				StatisticManager.last_game_difficulty,
				StatisticManager.last_run_time,
				StatisticManager.best_run_time
			]
		else:
			last_game_info.text = "Last game info:\nLose\nDifficulty: %s\nLast time: %.2fs\n--------------------------\nBest time: %s" % [
				StatisticManager.last_game_difficulty,
				StatisticManager.last_run_time,
				"N/A"
			]
	else:
		last_game_info.text = "Last game info:\nVictory\nDifficulty: %s\nLast time: %.2fs\n--------------------------\nBest time: %.2fs" % [
			StatisticManager.last_game_difficulty,
			StatisticManager.last_run_time,
			StatisticManager.best_run_time
		]
	
