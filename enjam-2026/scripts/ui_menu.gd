extends CanvasLayer

@export var game_manager : GameManager
@export var main_page : PanelContainer
@export var credits_page : PanelContainer
@export var ending_page : PanelContainer


var is_menu : bool = true
var active_ending: TextureRect

func _ready() -> void:
	game_manager.game_ended.connect(game_ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		toggle_menu()
	if Input.is_action_just_pressed("Run") and is_menu and not ending_page.visible:
		toggle_menu()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	main_page.hide()
	credits_page.show()


func _on_play_button_pressed() -> void:
	toggle_menu()

func toggle_menu():
	if is_menu:
		self.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		main_page.show()
		credits_page.hide()
		self.show()
	is_menu = !is_menu


func _on_return_pressed() -> void:
	credits_page.hide()
	main_page.show()

func game_ended(ending : GameManager.Ending, age : float):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	ending_page.show()
	for child in ending_page.get_children():
		child.hide()
	match ending:
		game_manager.Ending.OUT_OF_SCREEN:
			active_ending = $Endings/Early_Ending
		game_manager.Ending.TOO_EARLY:
			active_ending = $Endings/Early_Ending
		game_manager.Ending.GOOD:
			active_ending = $Endings/Good_Ending
		game_manager.Ending.TOO_LATE:
			active_ending = $Endings/Late_Ending
	var tween : Tween = create_tween().set_ignore_time_scale(true)
	active_ending.show()
	main_page.hide()
	tween.tween_property(active_ending, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0)
	tween.tween_property(active_ending, "modulate", Color(), 1)
	tween.tween_property(active_ending, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2)
	tween.tween_property($Endings/Ending_Button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2)
	$Endings/Ending_Button.show()


func _on_ending_button_pressed() -> void:
	var tween : Tween = create_tween().set_ignore_time_scale(true)
	tween.tween_property($Endings/Ending_Button, "modulate", Color.BLACK, 0.1)
	tween.tween_property(active_ending, "modulate", Color.BLACK, 2)
	await tween.finished
	game_manager.restart()
