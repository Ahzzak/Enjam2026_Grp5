class_name GameManager
extends Node

enum State { INTRO, RUNNING, RELEASED, GAME_OVER, ENDING, DEATH }

@export var player: Player

var state: State = State.INTRO:
	set(value):
		if value == state:
			return
		print(State.keys()[state], " → ", State.keys()[value])
		_exit_state(state)
		state = value
		_enter_state(state)


func _ready() -> void:
	assert(player != null, "GameManager : l'export player n'est pas assigné.")
	player.run_resumed.connect(_on_player_run_resumed)
	player.run_released.connect(_on_player_run_released)


func _on_player_run_resumed() -> void:
	if state == State.INTRO or state == State.RELEASED:
		state = State.RUNNING


func _on_player_run_released() -> void:
	if state == State.RUNNING:
		state = State.RELEASED


func _enter_state(_new_state: State) -> void:
	pass


func _exit_state(_old_state: State) -> void:
	pass
