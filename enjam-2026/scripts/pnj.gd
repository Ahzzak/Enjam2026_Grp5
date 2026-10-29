class_name Pnj
extends Node2D

@export var look: PnjLook
@export var happy: bool = true
@export var flipped: bool = false

@export_group("Respiration")
@export_range(0.0, 0.2, 0.005) var happy_stretch: float = 0.05
@export_range(0.0, 0.2, 0.005) var sad_stretch: float = 0.025
@export_range(0.1, 3.0, 0.05, "suffix:s") var happy_period: float = 0.5
@export_range(0.1, 3.0, 0.05, "suffix:s") var sad_period: float = 1.6

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	var texture := look.happy if happy else look.sad
	_sprite.texture = texture
	_sprite.offset.y = -texture.get_height() / 2.0
	_sprite.flip_h = flipped
	_breathe()


func _breathe() -> void:
	var stretch := happy_stretch if happy else sad_stretch
	var period := (happy_period if happy else sad_period) * randf_range(0.85, 1.15)
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_sprite, "scale", Vector2(1.0 - stretch, 1.0 + stretch), period / 2.0)
	tween.tween_property(_sprite, "scale", Vector2.ONE, period / 2.0)
	tween.custom_step(randf() * period)
