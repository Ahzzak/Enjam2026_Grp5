extends Node2D

@export var clock : Clock
@export var parallax : Parallax2D

var obstacles : Array[Node2D]

func _enter_tree() -> void:
	clock.on_beat.connect(spawn)

func spawn():
	if randi_range(0, 5) > 4:
		var obstacle : Node2D = preload("res://prefabs/obstacle.tscn").instantiate()
		add_child(obstacle)
		obstacle.global_position = Vector2(1920, 1080)
		obstacles.append(obstacle)
