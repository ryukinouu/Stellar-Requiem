extends Node3D

var paused = false

func _ready():
	$AnimationTree.active = true

func _input(event):
	if event.is_action_pressed("escape"):
		paused = !paused
		get_tree().paused = paused
		$GUI/Paused.visible = paused

func _on_settings_pressed():
	paused = true
	get_tree().paused = paused
	$GUI/Paused.visible = paused

func _on_unpause_pressed():
	paused = false
	get_tree().paused = paused
	$GUI/Paused.visible = paused
