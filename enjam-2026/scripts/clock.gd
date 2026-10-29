extends Node
class_name Clock

@export var player: Player
@export var music : AudioStreamPlayer
@export var playlist : Array[AudioStreamWAV]

var bpm : int = 144
var clock128 : float
var curr_time : int
var timer : float
var last_time : float
var is_slowed : bool
var part_loop : int = 0
var is_msc_started : bool = false

signal on_beat
signal on_end_part
signal delay_music

func _enter_tree() -> void:
	player.run_resumed.connect(start_music)

func _process(delta: float) -> void:
	if !is_msc_started: return
	timer += delta
	curr_time = floor((timer / 60 * (bpm * 2)))
	if curr_time != last_time:
		check_beat()
	last_time = curr_time
	
	music.pitch_scale = maxf(Engine.time_scale, 0.01)

func start_music():
	if is_msc_started:
		return
	else:
		curr_time = 0
		is_msc_started = true
		await delay_music
		music.play()

func check_beat() -> void:
	var bar : int = curr_time / 4 / 2
	var beat : int = curr_time % 32
	if beat == 0:
		beat = 32
	if beat == 10: delay_music.emit()
	if is_msc_started:
		on_beat.emit(bar, beat)

func _on_music_finished() -> void:
	return
	if part_loop > playlist.size():
		part_loop = 0
	part_loop = part_loop + 1
	print("loop : ", part_loop)
	music.stream = playlist.get(part_loop)
	music.play()
	on_end_part.emit()
