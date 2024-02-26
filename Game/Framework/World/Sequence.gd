extends Node3D

@onready var anim_tree = $AnimationTree

var base_score = 0

var can_pause = false
var paused = false

func game_loop():
	paused = false
	$GUI/Paused.visible = paused
	$Character.position = Vector3(0, 0.5, 0)
	Core.data["current_score"] = 0
	$GUI/HUD/SoloScore/Text.text = str("%07d" % Core.data["current_score"])
	$GUI/HUD/Score/Upper/Score.text = str("%07d" % Core.data["current_score"])
	$Song.wait_time = $Beatmap.song_length
	$Start.start()

func restart():
	var bm_scene = load("res://Game/Scenes/Beatmaps/" + $Beatmap.song_name + ".tscn")
	$Beatmap.free()
	var bm_instance = bm_scene.instantiate()
	add_child(bm_instance)
	game_loop()

func _ready():
	anim_tree.active = true
	$GUI/HUD/AnimationPlayer.active = true
	game_loop()

func _input(event):
	if event.is_action_pressed("escape"):
		if can_pause:
			paused = !paused
			get_tree().paused = paused
			$GUI/Paused.visible = paused

func _process(delta):
	var progress_ratio = $GUI/HUD/Score/Bar.value / $GUI/HUD/Score/Bar.max_value
	$GUI/HUD/Score/Glow.position.x = -1498 + $GUI/HUD/Score/Bar.size.x * progress_ratio

func _on_settings_pressed():
	if can_pause:
		paused = true
		get_tree().paused = paused
		$GUI/Paused.visible = paused

func _on_unpause_pressed():
	paused = false
	get_tree().paused = paused
	$GUI/Paused.visible = paused

func _on_timer_timeout():
	if can_pause:
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
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Return")
	can_pause = false
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_retry_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Return")
	Core.cooldown(0.5, func():
		restart()
	)

func _on_restart_pressed():
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Return")
	can_pause = false
	Core.cooldown(0.5, func():
		restart()
	)

func _on_start_timeout():
	can_pause = true
	$Song.start()
	$Score.start()

func _on_song_timeout():
	can_pause = false
	$GUI/End/Score.text = str(Core.data["current_score"])
	if Core.data["current_score"] > DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"]:
		DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"] = Core.data["current_score"]
		$GUI/End/NewHighScore.visible = true
	else:
		$GUI/End/NewHighScore.visible = false
	$GUI/End/HighScore.text = "HIGH SCORE: " + str(DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"])
	DataEngine.save_data()
