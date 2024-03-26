extends Node3D

@onready var anim_tree = $AnimationTree

var input_wait = null
var txt_btn = null
var last_btn = null

var save_path = "user://settings.dat"

func _ready():
	anim_tree.active = true
	for node in $Control/Apollo.get_children():
		node.get_node("Button/Text").text = Core.data["keybinds"][node.name]
	for node in $Control/Artemis.get_children():
		node.get_node("Button/Text").text = Core.data["keybinds"][node.name]
	
	var slider_value = load_hslider_value()
	$Control/Sliders/Brightness.value = slider_value

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

func _on_back_button_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_brightness_value_changed(value):
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	save_hslider_value(value)

func save_hslider_value(value):
	var save = FileAccess.open(save_path, FileAccess.WRITE)
	save.store_var(value)

func load_hslider_value():
	print("loaded")
	if FileAccess.file_exists(save_path):
		var save = FileAccess.open(save_path, FileAccess.READ)
		var data = save.get_var()
		return data
	else:
		return 0.8

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

# Apollo Keybindings
func _on_apollo_left_pressed():
	set_input_wait("apollo-left", $Control/Apollo/"apollo-left"/Button)

func _on_apollo_top_pressed():
	set_input_wait("apollo-top", $Control/Apollo/"apollo-top"/Button)

func _on_apollo_bottom_pressed():
	set_input_wait("apollo-bottom", $Control/Apollo/"apollo-bottom"/Button)

func _on_apollo_right_pressed():
	set_input_wait("apollo-right", $Control/Apollo/"apollo-right"/Button)

func _on_apollo_pause_pressed():
	set_input_wait("escape", $Control/Apollo/"apollo-pause"/Button)

# Artemis Keybindings
func _on_artemis_left_pressed():
	set_input_wait("artemis-left", $Control/Artemis/"artemis-left"/Button)

func _on_artemis_right_pressed():
	set_input_wait("artemis-right", $Control/Artemis/"artemis-right"/Button)

func _on_artemis_action1_pressed():
	set_input_wait("artemis-green", $Control/Artemis/"artemis-action1"/Button)

func _on_artemis_action2_pressed():
	set_input_wait("artemis-red", $Control/Artemis/"artemis-action2"/Button)

func _on_artemis_pause_pressed():
	set_input_wait("return", $Control/Artemis/"artemis-pause"/Button)

func set_input_wait(action_name: String, button: Control):
	if last_btn != button:
		input_wait = action_name
		txt_btn = button
		txt_btn.get_node("Text").text = "Press any key..."

func _on_texture_button_toggled(toggled_on):
	$AudioStreamPlayer.stream_paused = toggled_on
