class_name GameManager
extends Node

enum State { INTRO, RUNNING, RELEASED, GAME_OVER, ENDING, DEATH }

@export var player: Player

@export_group("Lâcher de Deeeeeeeeeeeeeey")
@export_range(0.05, 1.0, 0.01) var release_slowmo: float = 0.25
@export_range(0.5, 10.0, 0.1, "suffix:s") var release_grace: float = 3.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var resume_time: float = 0.25

var state: State = State.INTRO:
	set(value):
		if value == state:
			return
		print(State.keys()[state], " → ", State.keys()[value])
		_exit_state(state)
		state = value
		_enter_state(state)

var release_factor: float = 1.0

var _release_tween: Tween


func _ready() -> void:
	assert(player != null, "GameManager : l'export player n'est pas assigné.")
	player.run_resumed.connect(_on_player_run_resumed)
	player.run_released.connect(_on_player_run_released)


func _process(_delta: float) -> void:
	Engine.time_scale = maxf(0.0001, release_factor)


func _on_player_run_resumed() -> void:
	if state == State.INTRO or state == State.RELEASED:
		state = State.RUNNING


func _on_player_run_released() -> void:
	if state == State.RUNNING:
		state = State.RELEASED


func _on_release_finished() -> void:
	if state == State.RELEASED:
		state = State.GAME_OVER


func _enter_state(new_state: State) -> void:
	match new_state:
		State.RUNNING:
			_tween_release_factor(1.0, resume_time)
		State.RELEASED:
			_tween_release_factor(release_slowmo, release_grace)
			_release_tween.finished.connect(_on_release_finished)


func _exit_state(_old_state: State) -> void:
	pass


func _tween_release_factor(target: float, duration: float) -> void:
	if _release_tween:
		_release_tween.kill()
	_release_tween = create_tween().set_ignore_time_scale(true)
	_release_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_release_tween.tween_property(self, "release_factor", target, duration)
