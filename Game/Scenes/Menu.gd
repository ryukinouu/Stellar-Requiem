extends Node3D

var animation_player

func _ready():
	print("ready")
	animation_player = get_node("AnimationPlayer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Game/Scenes/Controllers.tscn")
