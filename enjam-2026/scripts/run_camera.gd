class_name RunCamera
extends Camera2D

signal player_left_screen

const PLAYER_HALF_WIDTH := 120.0 ##Du pif un peu

@export var player: Player
## 0 : suit l'ancre, 1 : suit le perso.
@export_range(0.0, 1.0, 0.01) var follow_player: float = 0.0
## Position à l'écran du point suivi, depuis le bord gauche.
@export_range(0, 1920, 1, "suffix:px") var screen_x: float = 400.0
@export_range(0.0, 2.0, 0.05, "suffix:s") var offscreen_grace: float = 0.5

var offscreen_ratio: float:
	get:
		return minf(_offscreen_time / maxf(offscreen_grace, 0.01), 1.0)

var _has_left_screen: bool = false

var _offscreen_time: float = 0.0


func _physics_process(delta: float) -> void:
	var followed_x := lerpf(player.anchor_x, player.position.x, follow_player)
	position.x = followed_x - screen_x
	if player.position.x + PLAYER_HALF_WIDTH < position.x:
		_offscreen_time += delta
	else:
		_offscreen_time = 0.0
	if not _has_left_screen and _offscreen_time > offscreen_grace:
		_has_left_screen = true
		player_left_screen.emit()
