extends Node2D

@export var clock : Clock
@export var player : Player
@export var beats_ahead : int = 5
@export var ground_y : float = 1017.0


func _enter_tree() -> void:
	clock.on_beat.connect(spawn)


func spawn():
	_free_passed_obstacles()
	if randi_range(0, 5) > 4:
		var obstacle : Node2D = preload("res://prefabs/obstacle.tscn").instantiate()
		add_child(obstacle)
		var spawn_distance := beats_ahead * 60.0 / clock.bpm * player.run_speed
		obstacle.global_position = Vector2(player.anchor_x + spawn_distance, ground_y)


func _free_passed_obstacles() -> void:
	for obstacle in get_children():
		if obstacle.global_position.x < player.anchor_x - 1000.0:
			obstacle.queue_free()
