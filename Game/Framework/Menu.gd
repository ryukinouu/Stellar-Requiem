extends Node3D

@onready var anim_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer

func _ready():
	$Music.volume_db = Core.data["settings"]["music-volume"]
	$SFX.volume_db = Core.data["settings"]["sfx-volume"]
	$Control/Control/Play.grab_focus()
	$Control/Characters.size = Vector2(1695, 1570)
	anim_tree.active = true

func _on_play_pressed():
	Core.sound_effect($SFX, "button-click")
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_credits_pressed():
	Core.sound_effect($SFX, "button-click")
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Credits.tscn")
	)

func _on_quit_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().quit()
	)

func _on_audio_stream_player_finished():
	$Music.play()

func _on_settings_pressed():
	Core.sound_effect($SFX, "button-click")
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Settings.tscn")
	)

func _on_audio_toggle_toggled(toggled_on):
	Core.sound_effect($SFX, "button-click")
	$Music.stream_paused = toggled_on

func _on_player_pressed():
	Core.sound_effect($SFX, "button-click")
	Core.data["apollo"] = true
	Core.data["artemis"] = true
	$Control/Control/Apollo/Header.self_modulate = Color("ffffff64")
	$Control/Control/Artemis/Header.self_modulate = Color("ffffff64")
	$"Control/Control/2Player/Header".self_modulate = Color("ffffff")


func _on_apollo_pressed():
	Core.sound_effect($SFX, "button-click")
	Core.data["apollo"] = true
	Core.data["artemis"] = false
	$Control/Control/Apollo/Header.self_modulate = Color("ffffff")
	$Control/Control/Artemis/Header.self_modulate = Color("ffffff64")
	$"Control/Control/2Player/Header".self_modulate = Color("ffffff64")


func _on_artemis_pressed():
	Core.sound_effect($SFX, "button-click")
	Core.data["apollo"] = false
	Core.data["artemis"] = true
	$Control/Control/Apollo/Header.self_modulate = Color("ffffff64")
	$Control/Control/Artemis/Header.self_modulate = Color("ffffff")
	$"Control/Control/2Player/Header".self_modulate = Color("ffffff64")

func _on_play_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_credits_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_settings_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_player_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_apollo_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_artemis_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_quit_mouse_entered():
	Core.sound_effect($SFX, "button-hover")


func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 648))    
