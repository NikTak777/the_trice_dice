extends Control

@onready var last_game_info: Label = $LastGameInfoContainer/LastGameInfoText

func _ready():
	# Подключение сигналов
	$VBoxContainer/Button.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/Button2.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/Button3.pressed.connect(_on_exit_button_pressed)
	
	if not Global.is_last_game_victory:
		last_game_info.text = ""
	else:
		last_game_info.text = "Last game info:\nDifficulty: %s\nTime: %.2f" % [
			Global.last_game_difficulty,
			Global.last_run_time
		]

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scr/Game/game.tscn")
	queue_free()

func _on_settings_button_pressed():
	var settings_scene = preload("res://scr/UserInterface/SettingsMenu/SettingsMenu.tscn").instantiate()
	get_tree().current_scene.add_child(settings_scene)

func _on_exit_button_pressed():
	get_tree().quit()
	
