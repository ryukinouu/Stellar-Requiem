extends Node3D

@onready var anim_tree = $AnimationTree

var input_wait = null
var txt_btn = null
var last_btn = null

var save_path = "user://settings.dat"

func _ready():
	$Music.volume_db = Core.data["settings"]["music-volume"]
	$Control/Sliders/Music.value = Core.data["settings"]["music-volume"]
	$Control/Sliders/Sfx.value = Core.data["settings"]["sfx-volume"]
	
	anim_tree.active = true
	for node in $Control/Apollo.get_children():
		node.get_node("Button/Text").text = Core.data["keybinds"][node.name]
	for node in $Control/Artemis.get_children():
		node.get_node("Button/Text").text = Core.data["keybinds"][node.name]

func _input(event):
	if input_wait != null and not event is InputEventMouseMotion:
		if event.is_pressed() and not event.is_echo():
			Core.sound_effect($SFX, "button-click")
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
	Core.data["settings"]["brightness"] = value

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

# Apollo Keybindings
func _on_apollo_left_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("apollo-left", $Control/Apollo/"apollo-left"/Button)

func _on_apollo_top_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("apollo-top", $Control/Apollo/"apollo-top"/Button)

func _on_apollo_bottom_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("apollo-bottom", $Control/Apollo/"apollo-bottom"/Button)

func _on_apollo_right_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("apollo-right", $Control/Apollo/"apollo-right"/Button)

func _on_apollo_pause_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("escape", $Control/Apollo/"apollo-pause"/Button)

# Artemis Keybindings
func _on_artemis_left_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("artemis-left", $Control/Artemis/"artemis-left"/Button)

func _on_artemis_right_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("artemis-right", $Control/Artemis/"artemis-right"/Button)

func _on_artemis_action1_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("artemis-green", $Control/Artemis/"artemis-action1"/Button)

func _on_artemis_action2_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("artemis-red", $Control/Artemis/"artemis-action2"/Button)

func _on_artemis_pause_pressed():
	Core.sound_effect($SFX, "button-click")
	set_input_wait("return", $Control/Artemis/"artemis-pause"/Button)

func set_input_wait(action_name: String, button: Control):
	if last_btn != button:
		input_wait = action_name
		txt_btn = button
		txt_btn.get_node("Text").text = "Press any key..."

func _on_texture_button_toggled(toggled_on):
	$AudioStreamPlayer.stream_paused = toggled_on

func _on_sfx_value_changed(value):
	Core.data["settings"]["sfx-volume"] = value
	$SFX.volume_db = value

func _on_music_value_changed(value):
	Core.data["settings"]["music-volume"] = value
	$Music.volume_db = value

func _on_back_button_mouse_entered():
	Core.sound_effect($SFX, "button-hover")
