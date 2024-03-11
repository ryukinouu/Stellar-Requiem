extends Node3D

@onready var anim_tree = $AnimationTree

@onready var onhit_midi = $MidiPlayer
@onready var prep_midi = $MidiPlayer2

var base_score = 0
var can_pause = true

func game_loop():
	$Character.position = Vector3(0, 0.5, 0)
	Core.data["current_score"] = 0
	Core.data["player_1"]["lives"] = 3
	$GUI/HUD/Side/Lives/One.visible = true
	$GUI/HUD/Side/Lives/Two.visible = true
	$GUI/HUD/Side/Lives/Three.visible = true
	$GUI/HUD/SoloScore/Text.text = str("%07d" % Core.data["current_score"])
	$GUI/HUD/Score/Upper/Score.text = str("%07d" % Core.data["current_score"])
	$Start.start()

func _on_main_midi_event(channel, event):
	pass # Replace with function body.

func _on_prep_midi_event(channel, event):
	pass # Replace with function body.

func _on_score_timeout():
	if can_pause:
		Core.data["current_score"] += 1
		base_score += 1
		if base_score >= onhit_midi.length * 1000:
			$Timer.stop()
		elif Core.data["current_score"] >= 1000000:
			$Timer.stop()
			Core.data["current_score"] = 1000000
		$GUI/HUD/SoloScore/Text.text = str("%07d" % Core.data["current_score"])
		$GUI/HUD/Score/Upper/Score.text = str("%07d" % Core.data["current_score"])

func _ready():
	anim_tree.active = true
	$GUI/HUD/AnimationPlayer.active = true
	game_loop()

func _on_main_midi_finished():
	$GUI/End/Score.text = str(Core.data["current_score"])
	if Core.data["current_score"] > DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"]:
		DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"] = Core.data["current_score"]
		$GUI/End/NewHighScore.visible = true
	else:
		$GUI/End/NewHighScore.visible = false
	$GUI/End/HighScore.text = "HIGH SCORE: " + str(DataEngine.save_info["songs"][$Beatmap.song_name]["high_score"])
	DataEngine.save_data()

func _on_start_timeout():
	$Score.start()
