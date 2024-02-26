extends Node3D

@onready var anim_tree = $AnimationTree
func _ready():
	anim_tree.active = true

func _on_texture_button_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)
