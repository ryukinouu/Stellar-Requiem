extends Node3D

@onready var anim_tree = $AnimationTree

func _ready():
	_newest_high_score()
	anim_tree.active = true

func _on_texture_button_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Levels/Meow.tscn")
	)


func _newest_high_score():
	$SongDescription/HighScore.text = str(DataEngine.save_info["songs"]["Meow"]["high_score"])

func _on_texture_button_2_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_audio_toggle_toggled(toggled_on):
	$AudioStreamPlayer.stream_paused = toggled_on
