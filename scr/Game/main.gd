extends Control

func _ready():
	# Загружаем главное меню
	var menu = preload("res://scr/UserInterface/MainMenu/MainMenu.tscn").instantiate()
	add_child(menu)
