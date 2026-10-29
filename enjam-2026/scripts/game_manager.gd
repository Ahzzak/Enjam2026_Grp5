class_name GameManager
extends Node

enum State { INTRO, RUNNING, RELEASED, GAME_OVER, ENDING, DEATH }

@export var player: Player
@export var run_camera: RunCamera

@export_group("Lâcher de Deeeeeeeeeeeeeey")
@export_range(0.05, 1.0, 0.01) var release_slowmo: float = 0.25
@export_range(0.5, 10.0, 0.1, "suffix:s") var release_grace: float = 3.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var resume_time: float = 0.25

@export_group("Fin de Partie")
@export_range(0.0, 5, 0.1, "suffix:s") var restart_delay: float = 1.0

var state: State = State.INTRO:
	set(value):
		if value == state:
			return
		print(State.keys()[state], " → ", State.keys()[value])
		_exit_state(state)
		state = value
		_enter_state(state)

var release_factor: float = 1.0

var end_factor: float = 1.0

var _release_tween: Tween

var _end_message: String = ""
var _can_restart: bool = false


func _ready() -> void:
	assert(player != null, "GameManager : l'export player n'est pas assigné.")
	assert(run_camera != null, "RunCamera : l'export camera n'est pas assigné.")
	player.run_resumed.connect(_on_player_run_resumed)
	player.run_released.connect(_on_player_run_released)
	run_camera.player_left_screen.connect(_on_camera_player_left_screen)


func _process(_delta: float) -> void:
	Engine.time_scale = maxf(0.0001, release_factor * end_factor)


func _unhandled_input(event: InputEvent) -> void:
	if _can_restart and event.is_action_pressed("Run"):
		_restart()

func _on_player_run_resumed() -> void:
	if state == State.INTRO or state == State.RELEASED:
		state = State.RUNNING


func _on_player_run_released() -> void:
	if state == State.RUNNING:
		state = State.RELEASED


func _on_release_finished() -> void:
	if state == State.RELEASED:
		state = State.GAME_OVER
		_game_over("Tu t’es arrêté trop tôt.")


func _on_camera_player_left_screen() -> void:
	if state == State.RUNNING or state == State.RELEASED:
		_game_over("Le monde ne t’a pas attendu.")


func _game_over(message: String) -> void:
	_end_message = message
	state = State.GAME_OVER

func _enter_state(new_state: State) -> void:
	match new_state:
		State.RUNNING:
			player.controls_enabled = true
			_tween_release_factor(1.0, resume_time)
		State.RELEASED:
			player.controls_enabled = false
			_tween_release_factor(release_slowmo, release_grace)
			_release_tween.finished.connect(_on_release_finished)
		State.GAME_OVER:
			player.controls_enabled = false
			create_tween().set_ignore_time_scale(true).tween_property(self, "end_factor", 0.01, 0.5)
			_show_end([_end_message], restart_delay)


func _exit_state(_old_state: State) -> void:
	pass


func _tween_release_factor(target: float, duration: float) -> void:
	if _release_tween:
		_release_tween.kill()
	_release_tween = create_tween().set_ignore_time_scale(true)
	_release_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_release_tween.tween_property(self, "release_factor", target, duration)


func _show_end(lines: Array, delay: float) -> void:
	for line in lines:
		print(line)
	await get_tree().create_timer(delay, true, false, true).timeout
	print("Appuie sur D pour recommencer")
	_can_restart = true


func _restart() -> void:
	_can_restart = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
