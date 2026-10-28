extends Node2D

@export var player: Player

var release_factor: float = 1.0


func _ready() -> void:
	player.run_released.connect(_on_player_run_released)
	player.run_resumed.connect(_on_player_run_resumed)


func _process(_delta: float) -> void:
	Engine.time_scale = maxf(0.0001, release_factor)


func _on_player_run_released() -> void:
	print("D lâché !")


func _on_player_run_resumed() -> void:
	print("D réappuyé !")


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_T:
			player.controls_enabled = not player.controls_enabled
			print("Contrôles : ", player.controls_enabled)
		KEY_Y:
			var target := 0.0 if player.speed_scale > 0.0 else 1.0
			create_tween().tween_property(player, "speed_scale", target, 1.5)
			print("speed_scale → ", target)
