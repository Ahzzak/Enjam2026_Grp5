extends Node2D

@export var player: Player


func _ready() -> void:
	player.run_released.connect(_on_player_run_released)
	player.run_resumed.connect(_on_player_run_resumed)


func _on_player_run_released() -> void:
	print("D lâché !")


func _on_player_run_resumed() -> void:
	print("D réappuyé !")
