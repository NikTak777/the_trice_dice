extends Node

var victory_scene: PackedScene

func _ready():
	show_victory_and_restart()

func show_victory_and_restart():
	Global.is_game_over = true
	
	var victory_label = victory_scene.instantiate()
	get_tree().get_root().add_child(victory_label)

	get_tree().paused = true

	var timer = Timer.new()
	timer.process_mode = Timer.PROCESS_MODE_ALWAYS
	timer.wait_time = 5
	timer.one_shot = true
	add_child(timer)
	timer.start()

	await timer.timeout

	get_tree().paused = false
	Global.is_game_over = false
	victory_label.queue_free()
	get_tree().change_scene_to_file("res://scr/Game/Main.tscn")
	queue_free()
