extends Node3D

@onready var anim_tree = $AnimationTree

var input_wait = null
var txt_btn = null

func _ready():
	anim_tree.active = true

func _input(event):
	if input_wait != null and not event is InputEventMouseMotion:
		InputMap.action_erase_events(input_wait)
		InputMap.action_add_event(input_wait, event)
		if txt_btn:
			txt_btn.text = event.as_text()
		input_wait = null
		txt_btn = null
		print(event)

func _on_texture_button_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

func _on_move_left_1_pressed():
	_set_input_wait("ui_left", $Control/Player1/left/MoveLeft_1/Text)

func _on_move_right_1_pressed():
	_set_input_wait("ui_right", $Control/Player1/right/MoveRight_1/Text)

func _on_action_1_pressed():
	_set_input_wait("ui_accept", $Control/Player1/action/Action_1/Text)

func _on_pause_1_pressed():
	_set_input_wait("ui_cancel", $Control/Player1/escape/Pause_1/Text)

func _set_input_wait(action_name: String, button: Control):
	input_wait = action_name
	txt_btn = button
	txt_btn.text = "Press any key..."
