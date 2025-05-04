extends Control

func _ready():
	# Подключаем сигналы, если не через редактор
	$VBoxContainer/Button.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/Button3.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scr/Game/game.tscn")
	queue_free()  # Удаляем меню

func _on_exit_button_pressed():
	get_tree().quit()
