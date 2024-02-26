extends Node3D

var base_score = 0

var paused = false

func _ready():
	$AnimationTree.active = true
	$GUI/HUD/AnimationPlayer.active = true
	Core.cooldown(10, func():
		$Timer.start()
		Core.cooldown($Beatmap.song_length, func():
			$GUI/End/Score.text = str(Core.data["current_score"])
			if Core.data["current_score"] > DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"]:
				DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"] = Core.data["current_score"]
				$GUI/End/NewHighScore.visible = true
			else:
				$GUI/End/NewHighScore.visible = false
			$GUI/End/HighScore.text = "HIGH SCORE: " + str(DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"])
			DataEngine.save_data()
		)
	)

func _input(event):
	if event.is_action_pressed("escape"):
		paused = !paused
		get_tree().paused = paused
		$GUI/Paused.visible = paused

func _process(delta):
	var progress_ratio = $GUI/HUD/Score/Bar.value / $GUI/HUD/Score/Bar.max_value
	$GUI/HUD/Score/Glow.position.x = -1498 + $GUI/HUD/Score/Bar.size.x * progress_ratio

func _on_settings_pressed():
	paused = true
	get_tree().paused = paused
	$GUI/Paused.visible = paused

func _on_unpause_pressed():
	paused = false
	get_tree().paused = paused
	$GUI/Paused.visible = paused

func _on_timer_timeout():
	Core.data["current_score"] += 1
	base_score += 1
	if base_score >= $Beatmap.song_length * 1000:
		$Timer.stop()
	elif Core.data["current_score"] >= 1000000:
		$Timer.stop()
		Core.data["current_score"] = 1000000
	$GUI/HUD/SoloScore/Text.text = str("%07d" % Core.data["current_score"])
	$GUI/HUD/Score/Upper/Score.text = str("%07d" % Core.data["current_score"])



func _on_exit_pressed():
	# When instancing a scene dynamically, connect its signals like this:
	get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
