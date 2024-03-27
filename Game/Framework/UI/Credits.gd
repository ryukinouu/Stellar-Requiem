extends Node3D

@onready var anim_tree = $AnimationTree

func _ready():
	$Music.volume_db = Core.data["settings"]["music-volume"]
	$SFX.volume_db = Core.data["settings"]["sfx-volume"]
	
	anim_tree.active = true

func _on_texture_button_pressed():
	Core.sound_effect($SFX, "button-click")
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_audio_stream_player_finished():
	$Music.play()

func _on_texture_button_mouse_entered():
	Core.sound_effect($SFX, "button-hover")
