class_name PnjSpawner
extends Node2D

@export var game_manager: GameManager
@export var camera: Camera2D
@export var pnj_scene: PackedScene
@export var looks: Array[PnjLook]

@export_group("Placement")
@export var feet_y: float = 825.0
@export var group_size: Vector2i = Vector2i(1, 4)
@export var spacing: Vector2 = Vector2(55.0, 85.0)
@export var group_gap: Vector2 = Vector2(300.0, 1000.0)

var _next_x: float = 0.0


func _process(_delta: float) -> void:
	var left := camera.position.x
	_next_x = maxf(_next_x, left)
	while _next_x < left + get_viewport_rect().size.x + 200.0:
		_spawn_group()
	for pnj in get_children():
		if pnj.position.x < left - 300.0:
			pnj.queue_free()


func _spawn_group() -> void:
	var previous: PnjLook = null
	for i in randi_range(group_size.x, group_size.y):
		var pnj: Pnj = pnj_scene.instantiate()
		pnj.look = _pick_look(previous)
		pnj.happy = randf() >= _sad_chance()
		pnj.flipped = randf() < 0.5
		pnj.position = Vector2(_next_x, feet_y + randf_range(0.0, 8.0))
		add_child(pnj)
		previous = pnj.look
		_next_x += randf_range(spacing.x, spacing.y)
	_next_x += randf_range(group_gap.x, group_gap.y)


func _pick_look(avoid: PnjLook) -> PnjLook:
	var look: PnjLook = looks.pick_random()
	while looks.size() > 1 and look == avoid:
		look = looks.pick_random()
	return look

func _sad_chance() -> float:
	var gm := game_manager
	return clampf((gm.age - gm.age_threshold_min) / (gm.age_threshold_max - gm.age_threshold_min), 0.0, 1.0)
