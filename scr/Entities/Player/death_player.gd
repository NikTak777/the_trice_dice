extends Node

var game_over_scene: PackedScene

func _ready():
	show_game_over_and_restart()

func show_game_over_and_restart():
	Global.is_game_over = true
	
	var game_over_label = game_over_scene.instantiate()
	get_tree().get_root().add_child(game_over_label)

	get_tree().paused = true

	var timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.wait_time = 5
	timer.one_shot = true
	add_child(timer)  # таймер живёт в этом контроллере
	timer.start()

	await timer.timeout

	get_tree().paused = false
	Global.is_game_over = false
	game_over_label.queue_free()
	get_tree().change_scene_to_file("res://scr/Game/Main.tscn")
	queue_free()
