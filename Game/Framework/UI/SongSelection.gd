extends Node3D

@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	_newest_high_score()
	anim_tree.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_texture_button_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Levels/Meow.tscn")
	)
	

func _newest_high_score():
	$SongDescBckgrnd/Description.text = "Song: Meow
	Artist: Zhehan
	BPM: 170
	Song Length: 2:10

	Difficulty: ★☆☆☆☆
	High Score: 
	" + str(DataEngine.save_info["songs"]["Meow"]["high_score"])


func _on_texture_button_2_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)
