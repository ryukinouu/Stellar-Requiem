extends Node3D
var scoreScript = preload("res://Game/Framework/Core/DataEngine.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	_newest_high_score()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Game/Scenes/Levels/Meow.tscn")

func _newest_high_score():
	var scoreScript_instance = scoreScript.new()
	$SongDescBckgrnd/Description.text = "Song: Meow
	Artist: Zhehan
	BPM: 170
	Song Length: 2:10

	Difficulty: ★☆☆☆☆
	High Score: 
	" + str(scoreScript_instance.save_info["songs"]["Meow"]["high_score"])
