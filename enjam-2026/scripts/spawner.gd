extends Node2D

@export var clock : Clock
@export var player : Player
@export var beats_ahead : int = 5
@export var ground_y : float = 1017.0
@export var obstacles : Array[PackedScene]

var music_part : int = 1
var spawn_count : int = 0
var leveldesign : Array[Array]

func _enter_tree() -> void:
	clock.on_beat.connect(spawn)
	clock.on_end_part.connect(new_part)
	load_csv()

func load_csv():
	var file = FileAccess.open("res://csv/Enjam2026_LD - Feuille 1.csv", FileAccess.READ)
	while !file.eof_reached():
		var line := file.get_line()
		leveldesign.append(line.split(","))
	file.close()

func spawn(bar : int, beat : int):
	_free_passed_obstacles()
	if bar > 72: return
	var type = leveldesign.get(music_part).get(beat)
	var obstacle : Node2D
	match type:
		"Jump":
			obstacle = obstacles.get(0).instantiate()
		"Slide":
			obstacle = obstacles.get(1).instantiate()
		"LongJump":
			obstacle = obstacles.get(0).instantiate()
		"x":
			obstacle = null
			return

	add_child(obstacle)
	var spawn_distance := beats_ahead * 60.0 / clock.bpm * player.run_speed
	obstacle.global_position = Vector2(player.anchor_x + spawn_distance, (ground_y - 100 ))
	spawn_count += 1


func new_part():
	music_part += 1

func _free_passed_obstacles() -> void:
	for obstacle in get_children():
		if obstacle.global_position.x < player.anchor_x - 1000.0:
			obstacle.queue_free()
