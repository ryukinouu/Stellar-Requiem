extends Node3D

@onready var anim_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer

func _ready():
	anim_tree.active = true

func _on_play_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Levels/Meow.tscn")
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
	Core.cooldown(1, func():
		get_tree().quit()
	)
