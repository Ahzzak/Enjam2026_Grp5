class_name RunCamera
extends Camera2D

@export var player: Player
## 0 : suit l'ancre, 1 : suit le perso.
@export_range(0.0, 1.0, 0.01) var follow_player: float = 0.0
## Position à l'écran du point suivi, depuis le bord gauche.
@export_range(0, 1920, 1, "suffix:px") var screen_x: float = 400.0


func _physics_process(_delta: float) -> void:
	var followed_x := lerpf(player.anchor_x, player.position.x, follow_player)
	position.x = followed_x - screen_x
