class_name RunCamera
extends Camera2D

signal player_left_screen

const PLAYER_HALF_WIDTH := 120.0 ##Du pif un peu

@export var player: Player
## 0 : suit l'ancre, 1 : suit le perso.
@export_range(0.0, 1.0, 0.01) var follow_player: float = 0.0
## Position à l'écran du point suivi, depuis le bord gauche.
@export_range(0, 1920, 1, "suffix:px") var screen_x: float = 400.0

var _has_left_screen: bool = false


func _physics_process(_delta: float) -> void:
	var followed_x := lerpf(player.anchor_x, player.position.x, follow_player)
	position.x = followed_x - screen_x
	if not _has_left_screen and player.position.x + PLAYER_HALF_WIDTH < position.x:
		_has_left_screen = true
		player_left_screen.emit()
