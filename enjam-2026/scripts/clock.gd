extends Node
class_name Clock

@export var player: Player
@export var music : AudioStreamPlayer

var bpm : int = 144
var clock128 : float
var curr_time : int
var timer : float
var last_time : float
var is_slowed : bool
var part_loop : int

signal on_beat
signal on_end_part

func _process(delta: float) -> void:
	timer += delta
	curr_time = floor((timer / 60 * bpm))
	if curr_time != last_time:
		check_beat()
		$Click.play()
		if music.playing == false :
			music.play()
			curr_time = 0
			part_loop = 0
		check_part()
	last_time = curr_time
	
	var scale : float = 1.0 if player.is_running else 0.5
	Engine.time_scale = scale
	music.pitch_scale = scale

func check_part():
	if curr_time % 3 == 0 :
		on_end_part.emit()
		part_loop += 1
		print(part_loop)
		if part_loop == 7:
			music.stream = preload("res://sounds/Music/Bridge_1.wav")
			music.play()
			part_loop = 0

func check_beat():
	var count : int = curr_time / 4
	on_beat.emit()
