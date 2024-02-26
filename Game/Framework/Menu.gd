extends Node3D

var animation_player

func _ready():
	print('menu ready') 
	animation_player = get_node("AnimationPlayer")
	print("peep")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_pressed():
	print("play")
	get_tree().change_scene_to_file("res://Game/Scenes/Menu/Controllers.tscn")


func _on_credits_pressed():
	print("credits")
	get_tree().change_scene_to_file("res://Game/Scenes/Menu/Credits.tscn")


func _on_quit_pressed():
	get_tree().quit()
