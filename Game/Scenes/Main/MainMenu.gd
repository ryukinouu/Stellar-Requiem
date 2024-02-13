extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.echo:
		# Start the fade-out animation on the ColorRect
		$CanvasLayer/AnimationPlayer.play("fade_to_black")

func _on_fade_to_black_finished(animation_name):
	if animation_name == "fade_to_black":
		# Change the scene or perform other actions here
		get_tree().change_scene_to_file("res://Game/Scenes/Levels/Tutorial.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
