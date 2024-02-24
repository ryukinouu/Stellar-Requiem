extends Node3D

var paused = false

func _ready():
	$AnimationTree.active = true
	#$Environment/GrassEffects.visible = true

func _input(event):
	if event.is_action_pressed("escape"):
		print("PAUSED")
		if paused:
			$AnimationPlayer.stop(false)
		else:
			$AnimationPlayer.stop(true)
