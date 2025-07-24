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
	# var victory_node = Node.new()
	# victory_node.set_script(preload("res://scr/Entities/Player/victory_player.gd"))
	# victory_node.victory_scene = preload("res://scr/UserInterface/VictoryLabel/Victory.tscn")
	# get_tree().get_root().add_child(victory_node)
	pass
