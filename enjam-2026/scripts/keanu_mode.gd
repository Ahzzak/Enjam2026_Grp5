extends Sprite2D

@export var player : Player

var keanu : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Keanu_Mode"):
		if keanu:
			pass
		elif !keanu:
			pass
