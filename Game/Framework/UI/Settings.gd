extends Node3D

@onready var anim_tree = $AnimationTree

var input_wait = null
var txt_btn = null
var last_btn = null

func _ready():
	anim_tree.active = true
	for node in $Control/Player1.get_children():
		node.get_node("Button/Text").text = Core.data["keybinds"][node.name]

func _input(event):
	if input_wait != null and not event is InputEventMouseMotion:
		if event.is_pressed() and not event.is_echo():
			InputMap.action_erase_events(input_wait)
			InputMap.action_add_event(input_wait, event)
			if txt_btn:
				var display_text = simplify_button_name(event.as_text())
				txt_btn.get_node("Text").text = display_text
				Core.data["keybinds"][input_wait] = display_text
				last_btn = txt_btn
			input_wait = null
			txt_btn = null
			print(event.as_text())
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			last_btn = null

func simplify_button_name(button_text: String) -> String:
	if button_text.begins_with("Joypad Button"):
		var parts = button_text.split(" (")
		if parts.size() > 1:
			var name_parts = parts[1].replace(")", "").split(", ")
			if name_parts.size() > 0:
				return name_parts[0]
	return button_text

func _on_texture_button_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

func _on_move_left_1_pressed():
	set_input_wait("left", $Control/Player1/left/Button)

func _on_move_right_1_pressed():
	set_input_wait("right", $Control/Player1/right/Button)

func _on_action_1_pressed():
	set_input_wait("action", $Control/Player1/action/Button)

func _on_pause_1_pressed():
	set_input_wait("escape", $Control/Player1/escape/Button)

func set_input_wait(action_name: String, button: Control):
	if last_btn != button:
		input_wait = action_name
		txt_btn = button
		txt_btn.get_node("Text").text = "Press any key..."

func _on_texture_button_toggled(toggled_on):
	$AudioStreamPlayer.stream_paused = toggled_on
