extends Node3D

@onready var anim_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer

func _ready():
	$Control/Characters.size = Vector2(1695, 1570)
	anim_tree.active = true

func _on_play_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_credits_pressed():
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
	$AudioStreamPlayer.play()

func _on_settings_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Settings.tscn")
	)
