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
	if DataEngine.save_info["high_scores"].has("Meow"):
		$SongDescription/HighScore.text = str(DataEngine.save_info["high_scores"]["Meow"])
	else:
		$SongDescription/HighScore.text = "0000000"

func _on_texture_button_2_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_audio_toggle_toggled(toggled_on):
	$AudioStreamPlayer.stream_paused = toggled_on


func _on_texture_button_3_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Levels/Music Box.tscn")
	)
