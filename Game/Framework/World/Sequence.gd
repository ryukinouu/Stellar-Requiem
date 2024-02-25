extends Node3D

var base_score = 0

var paused = false

func _ready():
	$AnimationTree.active = true
	Core.cooldown(10, func():
		$Timer.start()
	)

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

func _on_timer_timeout():
	Core.data["current_score"] += round(50000 / ($Beatmap.song_length * 100))
	base_score += round(500000 / ($Beatmap.song_length * 100))
	if base_score >= 500000:
		$Timer.stop()
	elif Core.data["current_score"] >= 1000000:
		$Timer.stop()
		Core.data["current_score"] = 1000000
	$GUI/HUD/SoloScore/Text.text = str("%07d" % Core.data["current_score"])
	$GUI/HUD/Score/Upper/Score.text = str("%07d" % Core.data["current_score"])
