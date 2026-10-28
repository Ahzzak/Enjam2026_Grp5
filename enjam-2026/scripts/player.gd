extends CharacterBody2D

@export var sprite : Sprite2D
@export var parallax : Parallax2D

const SPEED = 400.0
const JUMP_VELOCITY = -1500.0
const GRAVITY = Vector2(0.0,3500.0)

var is_moving : bool = false
var scroll_speed : float

func _ready() -> void:
	flip_loop()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("MoveLeft", "MoveRight")
	if direction:
		scroll_speed = direction * SPEED
		is_moving = true
	else:
		scroll_speed = move_toward(velocity.x, 12, SPEED)
		is_moving = false
	parallax.autoscroll.x = -scroll_speed
	$"../Spawner".autoscroll.x = -scroll_speed
	move_and_slide()

func flip_loop():
	await get_tree().create_timer(0.5).timeout
	if is_moving:
		sprite.flip_h = !sprite.flip_h
	flip_loop()
