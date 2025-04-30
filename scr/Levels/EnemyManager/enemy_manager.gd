extends Node

# Общее число противников на уровне
var enemy_count: int = 0

# Ссылка на Victory-сцену (PackedScene)
@export var victory_scene: PackedScene
# Время отображения окна Victory (в секундах)
@export var victory_delay: float = 3.0

func add_enemy():
	enemy_count += 1

func enemy_died():
	enemy_count -= 1
	if enemy_count <= 0:
		_on_all_enemies_killed()
		

func _on_all_enemies_killed():
	var victory_scene = preload("res://scr/UserInterface/VictoryLabel/Victory.tscn")
	var victory_label = victory_scene.instantiate()
	get_tree().get_root().add_child(victory_label)
	
	get_tree().paused = true
	
	var timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.wait_time = 5
	timer.one_shot = true
	add_child(timer)
	timer.start()

	await timer.timeout

	get_tree().paused = false
	
	victory_label.queue_free()
	
	get_tree().change_scene_to_file("res://scr/Game/Main.tscn")
	
	queue_free()
