class_name Player
extends CharacterBody2D

signal run_released
signal run_resumed

enum State { RUN, AIR, SLIDE, DIVE }

const OFFSET_TOLERANCE := 1.0

@export_group("Course")
@export_range(0, 3000, 10, "suffix:px/s") var run_speed: float = 800.0

@export_group("Saut")
@export_range(0, 1000, 1, "suffix:px") var jump_height: float = 440.0
@export_range(0, 1000, 1, "suffix:px") var min_jump_height: float = 110.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var time_to_apex: float = 0.3
@export_range(0.05, 2.0, 0.01, "suffix:s") var time_to_land: float = 0.2

@export_group("Slide")
@export_range(0, 1000, 1, "suffix:px") var slide_boost_distance: float = 250.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var slide_boost_time: float = 0.4
## Fraction de run_speed utilisée pour revenir à l'ancre.
@export_range(0.0, 1.0, 0.01) var anchor_return_ratio: float = 0.35
@export_range(0, 6000, 10, "suffix:px/s") var dive_speed: float = 2500.0
@export_range(0, 1000, 1, "suffix:px") var slide_jump_boost_distance: float = 150.0
## Avance max devant l'ancre.
@export_range(0, 1500, 1, "suffix:px") var max_boost_offset: float = 1100.0
## Recul max derrière l'ancre avant que le slide s'arrête.
@export_range(0, 1000, 1, "suffix:px") var max_slide_lag: float = 0.0

@export_group("Tolérances")
@export_range(0.0, 0.5, 0.01, "suffix:s") var jump_buffer_time: float = 0.12
@export_range(0.0, 0.5, 0.01, "suffix:s") var coyote_time: float = 0.1

@export_group("Juice")
@export var jump_stretch: Vector2 = Vector2(0.75, 1.3)
@export var land_squash: Vector2 = Vector2(1.3, 0.7)
@export var slide_squash: Vector2 = Vector2(1.25, 0.85)
@export_range(0.01, 1.0, 0.01, "suffix:s") var squash_duration: float = 0.51

var jump_gravity: float:
	get:
		return 2.0 * jump_height / (time_to_apex * time_to_apex)

var fall_gravity: float:
	get:
		return 2.0 * jump_height / (time_to_land * time_to_land)

var jump_speed: float:
	get:
		return 2.0 * jump_height / time_to_apex

var min_jump_speed: float:
	get:
		return sqrt(2.0 * jump_gravity * min_jump_height)

var slide_deceleration: float:
	get:
		return 2.0 * slide_boost_distance / (slide_boost_time * slide_boost_time)

var state: State = State.RUN:
	set(value):
		if value == state:
			return
		_exit_state(state)
		state = value
		_enter_state(state)

var is_running: bool = false

var controls_enabled: bool = true

##Pour la fin
var speed_scale: float = 1.0

## Position de course, calée sur la musique. La caméra la suit.
var anchor_x: float:
	get:
		return _anchor_x

var _time_since_jump_press: float = INF
var _time_since_on_floor: float = INF
var _anchor_x: float
var _boost_speed: float = 0.0
var _has_started: bool = false
var _slide_exhausted: bool = false
var _squash_tween: Tween

var _anchor_offset: float:
	get:
		return position.x - _anchor_x

@onready var _visual: Node2D = $Visual
@onready var _stand_shape: CollisionShape2D = $StandShape
@onready var _slide_shape: CollisionShape2D = $SlideShape
@onready var _ceiling_check: ShapeCast2D = $CeilingCheck
@onready var _sprite: AnimatedSprite2D = $Visual/Sprite


func _ready() -> void:
	_anchor_x = position.x


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Jump") and controls_enabled:
		_time_since_jump_press = 0.0


func _physics_process(delta: float) -> void:
	if delta <= 0.0:
		return
	_update_run_input()
	match state:
		State.RUN:
			_physics_run(delta)
		State.AIR:
			_physics_air(delta)
		State.SLIDE:
			_physics_slide(delta)
		State.DIVE:
			_physics_dive(delta)

	_update_horizontal(delta)
	var was_on_floor := is_on_floor()
	move_and_slide()
	if is_on_floor() and not was_on_floor:
		_handle_landing()
	_update_animation()

	_time_since_jump_press += delta
	if is_on_floor():
		_time_since_on_floor = 0.0
	else:
		_time_since_on_floor += delta


func _update_run_input() -> void:
	if not controls_enabled:
		return
	var pressed := _action_pressed("Run")
	if pressed == is_running:
		return
	is_running = pressed
	if is_running:
		_has_started = true
		run_resumed.emit()
	else:
		run_released.emit()


func _physics_run(_delta: float) -> void:
	if not _action_pressed("Slide"):
		_slide_exhausted = false
	if _try_jump():
		return
	if not is_on_floor():
		state = State.AIR
	elif _action_pressed("Slide") and not _slide_exhausted:
		state = State.SLIDE


func _physics_air(delta: float) -> void:
	if _try_jump():
		return
	if _action_just_pressed("Slide"):
		state = State.DIVE
		return
	if velocity.y < -min_jump_speed and not _action_pressed("Jump"):
		velocity.y = -min_jump_speed
	var current_gravity: float
	if velocity.y < 0.0:
		current_gravity = jump_gravity
	else:
		current_gravity = fall_gravity
	velocity.y += current_gravity * delta
	if is_on_floor():
		state = State.RUN


func _physics_slide(_delta: float) -> void:
	var can_stand_up := _can_stand_up()
	if can_stand_up and _try_jump():
		_add_boost(slide_jump_boost_distance)
		return
	var exhausted := _has_started and _boost_speed <= 0.0 \
		and _anchor_offset <= -max_slide_lag + OFFSET_TOLERANCE
	if not is_on_floor():
		state = State.AIR
	elif (exhausted or not _action_pressed("Slide")) and can_stand_up:
		_slide_exhausted = exhausted
		state = State.RUN


func _physics_dive(_delta: float) -> void:
	velocity.y = dive_speed
	if is_on_floor():
		state = State.SLIDE


func _try_jump() -> bool:
	var wants_jump := _time_since_jump_press <= jump_buffer_time
	var can_jump := _time_since_on_floor <= coyote_time
	if not (wants_jump and can_jump):
		return false
	velocity.y = -jump_speed
	_time_since_jump_press = INF
	_time_since_on_floor = INF
	state = State.AIR
	_squash(jump_stretch)
	return true


func _can_stand_up() -> bool:
	_ceiling_check.force_shapecast_update()
	return not _ceiling_check.is_colliding()


func _action_pressed(action: StringName) -> bool:
	return controls_enabled and Input.is_action_pressed(action)


func _action_just_pressed(action: StringName) -> bool:
	return controls_enabled and Input.is_action_just_pressed(action)


func _update_horizontal(delta: float) -> void:
	var speed := run_speed * speed_scale if _has_started else 0.0
	if _boost_speed > 0.0:
		velocity.x = speed + _boost_speed
		_boost_speed = maxf(_boost_speed - slide_deceleration * delta, 0.0)
	else:
		var return_speed := run_speed * speed_scale * anchor_return_ratio
		var target_offset := -max_slide_lag if state == State.SLIDE and _has_started else 0.0
		velocity.x = speed + clampf((target_offset - _anchor_offset) / delta, -return_speed, return_speed)
	_anchor_x += speed * delta


func _add_boost(distance: float) -> void:
	if slide_deceleration <= 0.0:
		return
	var remaining := _boost_speed * _boost_speed / (2.0 * slide_deceleration)
	var room := maxf(max_boost_offset - _anchor_offset - remaining, 0.0)
	var added := minf(distance, room)
	_boost_speed = sqrt(_boost_speed * _boost_speed + 2.0 * slide_deceleration * added)


func _update_animation() -> void:
	match state:
		State.RUN:
			_sprite.play("run" if _has_started and speed_scale > 0.0 else "idle")
		State.AIR:
			_sprite.play("jump" if velocity.y < 0.0 else "fall")
		State.SLIDE:
			_sprite.play("slide")
		State.DIVE:
			_sprite.play("dive")


func _handle_landing() -> void:
	_squash(land_squash)


func _squash(amount: Vector2) -> void:
	if _squash_tween:
		_squash_tween.kill()
	_visual.scale = amount
	_squash_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_squash_tween.tween_property(_visual, "scale", Vector2.ONE, squash_duration)


func _enter_state(new_state: State) -> void:
	match new_state:
		State.SLIDE:
			_squash(slide_squash)
			_add_boost(slide_boost_distance)
			_stand_shape.disabled = true
			_slide_shape.disabled = false
		State.DIVE:
			velocity.y = dive_speed


func _exit_state(old_state: State) -> void:
	match old_state:
		State.SLIDE:
			_stand_shape.disabled = false
			_slide_shape.disabled = true
