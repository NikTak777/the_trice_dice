extends CharacterBody2D

const SPEED = 500.0

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * SPEED

func _physics_process(delta):
	get_input()
	move_and_slide()


func _on_pause_pressed() -> void:
	get_tree().change_scene_to_file("res://scr/UserInterface/main_menu.tscn")
