extends Control

func _ready() -> void:
	visible = false  # Меню скрыто по умолчанию

func _process(_delta):
	if Input.is_action_just_pressed("pause") and not Global.is_game_over:
		toggle_menu()

func toggle_menu():
	visible = !visible
	get_tree().paused = visible  # Ставим или снимаем паузу

func _on_start_pressed() -> void:
	get_tree().paused = false  # Убираем паузу
	visible = false  # Скрываем меню
	get_tree().reload_current_scene()  # Перезапускаем игру

func _on_resume_pressed() -> void:
	toggle_menu() # Возобновление игры

func _on_exit_pressed() -> void:
	get_tree().quit()  # Закрываем игру
