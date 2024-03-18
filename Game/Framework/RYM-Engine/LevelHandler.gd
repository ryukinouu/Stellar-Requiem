extends Node3D

@onready var midi = $Midi
@onready var music = $Main/Camera3D/Music
@onready var misc = $Main/Misc

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

@onready var d_lane_left = $Main/Notes/d_left
@onready var d_lane_top = $Main/Notes/d_top
@onready var d_lane_bottom = $Main/Notes/d_bottom
@onready var d_lane_right = $Main/Notes/d_right

@onready var apollo = $Main/Apollo
@onready var apollo_animtree = $Main/Apollo/AnimationTree
@onready var artemis = $Main/Artemis

@onready var apollo_v = $"Main/Player1-Visuals"
@onready var artemis_v = $"Main/Player2-Visuals"

@onready var score_timer = $Score

@onready var music_length = music.stream.get_length()

@export var song_name : String = "Music Box"
@export var map_speed : int = 30
@export var channel_midi : int = 1
@export var spawn_distance : int = 100

@export var drum_notes : int = 110
@export var guitar_notes : int = 0

@export var initial_delay : float = 4.0
@export var wav_delay : float = 6.0
@export var music_first : bool = false

var note_scene = load("res://Game/Scenes/Notes/Note.tscn")
var apollo_afterimage = load("res://Game/Scenes/Core/Apollo_Afterimage.tscn")
var miss_texture = load("res://Assets/Textures/Indicators/MISS.png")
var great_texture = load("res://Assets/Textures/Indicators/GREAT!.png")
var good_texture = load("res://Assets/Textures/Indicators/GOOD!.png")
var bad_texture = load("res://Assets/Textures/Indicators/BAD.png")
var stellar_texture = load("res://Assets/Textures/Indicators/STELLAR!.png")

var mapping = {
	36: "d_left",
	38: "d_top",
	40: "d_bottom",
	41: "d_right"
}
var canhit = {
	"d_left": [], 
	"d_top": [], 
	"d_bottom": [], 
	"d_right": []
}
var note_values = {
	"miss": 0,
	"bad": 0,
	"good": 0,
	"great": 0,
	"stellar": 0
}
var tweens = {}
var char_lanes = {
	"apollo": {
		"current": "top",
		"left": 33,
		"top": 25,
		"bottom": 17,
		"right": 9
	},
	"artemis": {
		"current": "bottom",
		"left": -9,
		"top": -17,
		"bottom": -25,
		"right": -3
	},
}

var artemis_boost_speed = 50.0
var artemis_move_speed = 15.0
var artemis_initial_speed = artemis_boost_speed
var artemis_tween

var delta_stellar = 0.05
var delta_great = 0.05
var delta_good = 0.05
var delta_bad = 0.05
var delta_miss = 0.1
var hit_delta = delta_stellar + delta_great + delta_good + delta_bad + delta_miss

var paused = false
var can_pause = false
var apollo_notes_disabled = false
var artemis_notes_disabled = false
var total_notes = 0
var base_score = 0
var notes_score = 0

func get_lane(direction):
	if direction == "d_left":
		return d_lane_left
	elif direction == "d_top":
		return d_lane_top
	elif direction == "d_bottom":
		return d_lane_bottom
	elif direction == "d_right":
		return d_lane_right

func loading(out):
	if out:
		$GUI/Loading.color = Color.BLACK
		$GUI/Loading.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property(
			$GUI/Loading, 
			"color", 
			Color.TRANSPARENT, 
			1
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(func():
			$GUI/Loading.visible = false
		)
	else:
		$GUI/Loading.color = Color.TRANSPARENT
		$GUI/Loading.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property(
			$GUI/Loading, 
			"color", 
			Color.BLACK, 
			1
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _ready():
	var anim = anim_player.get_animation("Playing")
	var tmain_pos = anim.find_track("Main:position", 0)
	var kmain_pos = anim.track_find_key(tmain_pos, 600.0, true)
	anim.track_set_key_value(tmain_pos, kmain_pos, Vector3(0, 0, 600.0 * map_speed))
	
	var tcam_pos = anim.find_track("Main/Camera3D:position", 0)
	var kcam_pos = anim.track_find_key(tcam_pos, 4.0, true)
	
	$GUI/HUD.visible = true
	$GUI/End.visible = false
	$GUI/HUD/Score/SongProgress.value = 0
	$GUI/HUD/Score/Bar.value = 0
	$GUI/HUD/SoloScore/Text.text = "0000000"
	$GUI/HUD/SoloScore2/Text.text = "0000000"
	$GUI/HUD/Score/Upper/Score.text = "0000000"
	
	if Core.data["apollo"] and Core.data["artemis"]:
		total_notes = guitar_notes + drum_notes
		apollo.position = Vector3(3, -2, 0)
		artemis.position = Vector3(-3, -2, 0)
		
		apollo_notes_disabled = false
		artemis_notes_disabled = false
		$GUI/HUD/Score/Upper/Score.visible = true
		$GUI/HUD/SoloScore.visible = false
		$GUI/HUD/Side.visible = true
		$GUI/HUD/Score/Upper/Player1.visible = true
		$GUI/HUD/SoloScore2.visible = false
		$GUI/HUD/Side2.visible = true
		$GUI/HUD/Score/Upper/Player2.visible = true
		
		anim.track_set_key_value(tcam_pos, kcam_pos, Vector3(0, 20, -16))
		Core.cooldown(2, func():
			var tween = get_tree().create_tween()
			tween.tween_property(
				apollo, 
				"position:x", 
				char_lanes["apollo"]["top"], 
				2
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
			tween = get_tree().create_tween()
			tween.tween_property(
				artemis, 
				"position:x", 
				char_lanes["artemis"]["bottom"], 
				2
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		)
	elif Core.data["apollo"]:
		total_notes = drum_notes
		apollo.position = Vector3(0, -2, 0)
		artemis.visible = false
		artemis_v.visible = false
		
		apollo_notes_disabled = false
		artemis_notes_disabled = true
		$GUI/HUD/Score/Upper/Score.visible = false
		$GUI/HUD/SoloScore.visible = true
		$GUI/HUD/Side.visible = true
		$GUI/HUD/Score/Upper/Player1.visible = true
		$GUI/HUD/SoloScore2.visible = false
		$GUI/HUD/Side2.visible = false
		$GUI/HUD/Score/Upper/Player2.visible = false
		
		anim.track_set_key_value(tcam_pos, kcam_pos, Vector3(21, 16, -14))
		Core.cooldown(2, func():
			var tween = get_tree().create_tween()
			tween.tween_property(
				apollo, 
				"position:x", 
				char_lanes["apollo"]["top"], 
				2
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		)
	else:
		total_notes = guitar_notes
		artemis.position = Vector3(0, -2, 0)
		apollo.visible = false
		apollo_v.visible = false
		
		apollo_notes_disabled = true
		artemis_notes_disabled = false
		$GUI/HUD/Score/Upper/Score.visible = false
		$GUI/HUD/SoloScore.visible = false
		$GUI/HUD/Side.visible = false
		$GUI/HUD/Score/Upper/Player1.visible = false
		$GUI/HUD/SoloScore2.visible = true
		$GUI/HUD/Side2.visible = true
		$GUI/HUD/Score/Upper/Player2.visible = true
		
		anim.track_set_key_value(tcam_pos, kcam_pos, Vector3(-21, 16, -14))
		Core.cooldown(2, func():
			var tween = get_tree().create_tween()
			tween.tween_property(
				artemis, 
				"position:x", 
				char_lanes["artemis"]["bottom"], 
				2
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		)
	
	note_values["stellar"] = snapped(500000 / total_notes, 1)
	note_values["great"] = snapped(note_values["stellar"] * 0.8, 1)
	note_values["good"] = snapped(note_values["stellar"] * 0.6, 1)
	note_values["bad"] = snapped(note_values["stellar"] * 0.2, 1)
	note_values["miss"] = 0
	
	loading(true)
	anim_tree.active = true
	if music_first:
		Core.cooldown(initial_delay, func():
			can_pause = true
			begin_song()
			score_timer.start()
			music.play()
			Core.cooldown(wav_delay - 2, func():
				midi.play()
			)
		)
	else:
		Core.cooldown(initial_delay, func():
			can_pause = true
			begin_song()
			score_timer.start()
			midi.play()
			Core.cooldown(2, func():
				music.play()
			)
		)

func begin_song():
	$GUI/HUD/Score/Bar.value = 0
	base_score = 0
	notes_score = 0
	var tween = get_tree().create_tween()
	tween.tween_property(
		$GUI/HUD/Score/SongProgress, 
		"value", 
		1000000, 
		music_length
	)
	tween = get_tree().create_tween()
	tween.tween_property(
		self, 
		"base_score", 
		500000, 
		music_length
	)

func _on_note_event(channel, event):
	if event.type == SMF.MIDIEventType.note_on:
		if channel.number == channel_midi - 1: 
			if event.note in mapping.keys():
				# SPAWN
				var note_direction = mapping[event.note]
				if note_direction.substr(0, 2) == "d_" and apollo_notes_disabled:
					return
				
				var note_instance = note_scene.instantiate()
				var mesh_instance_paths = ["Sphere", "Sphere_001", "Sphere_002", "Sphere_003", "Sphere_004"]
				for mesh_instance_path in mesh_instance_paths:
					var mesh_instance = note_instance.get_node("DefaultNoteWhite/Armature/Skeleton3D/" + mesh_instance_path)
					if mesh_instance and mesh_instance is MeshInstance3D:
						var mesh = mesh_instance.mesh
						if mesh:
							for surface in range(mesh.get_surface_count()):
								var mat = mesh.surface_get_material(surface)
								if mat:
									var new_mat = mat.duplicate()
									mesh.surface_set_material(surface, new_mat)
				
				get_lane(note_direction).add_child(note_instance)
				note_instance.position.z = spawn_distance
				
				var tween = get_tree().create_tween()
				tween.tween_property(
					note_instance, 
					"position:z", 
					-spawn_distance, 
					2 * 2
				)
				tween.tween_callback(note_instance.queue_free)
				
				# HIT WINDOW
				Core.cooldown(2 - hit_delta, func():
					canhit[note_direction].append(note_instance)
					tweens[note_instance] = tween
					Core.cooldown(hit_delta + delta_miss, func():
						if note_instance in canhit[mapping[event.note]]:
							canhit[mapping[event.note]].erase(note_instance)
							tweens.erase(note_instance)
					)
				)
				
				Core.cooldown(2 - hit_delta, func():
					change_indicator(note_instance, "Miss", "Miss")
					Core.cooldown(delta_miss, func():
						change_indicator(note_instance, "Miss", "Bad")
						Core.cooldown(delta_bad, func():
							change_indicator(note_instance, "Bad", "Good")
							Core.cooldown(delta_good, func():
								change_indicator(note_instance, "Good", "Great")
								Core.cooldown(delta_great, func():
									change_indicator(note_instance, "Great", "Stellar")
									Core.cooldown(delta_stellar, func():
										change_indicator(note_instance, "Stellar", "Miss")
									)
								)
							)
						)
					)
				)

func change_indicator(note, old, new):
	if note:
		note.get_node(old).name = new

func note_on_hit(note):
	var anim_tree = note.get_node("AnimationTree")
	var anim_player = note.get_node("AnimationPlayer")
	var anim = anim_tree.get("parameters/playback")
	anim.travel("hit")
	tweens[note].kill()
	Core.cooldown(anim_player.get_animation("hit").length, note.queue_free)
	if note.get_node_or_null("Great"):
		note.get_node("Indicator").mesh.material.albedo_texture = great_texture
		notes_score += note_values["great"]
	elif note.get_node_or_null("Good"):
		note.get_node("Indicator").mesh.material.albedo_texture = good_texture
		notes_score += note_values["good"]
	elif note.get_node_or_null("Bad"):
		note.get_node("Indicator").mesh.material.albedo_texture = bad_texture
		notes_score += note_values["bad"]
	elif note.get_node_or_null("Stellar"):
		note.get_node("Indicator").mesh.material.albedo_texture = stellar_texture
		notes_score += note_values["stellar"]
	elif note.get_node_or_null("Miss"):
		note.get_node("Indicator").mesh.material.albedo_texture = miss_texture
		notes_score += note_values["miss"]

func apollo_afterimage_effect():
	var apollo_effect = apollo_afterimage.instantiate()
	misc.add_child(apollo_effect)
	apollo_effect.position = Vector3(
		char_lanes["apollo"][char_lanes["apollo"]["current"]],
		-2,
		0
	)
	Core.cooldown(0.2, apollo_effect.queue_free)

func _input(event):
	if event.is_action_pressed("escape"):
		if can_pause:
			paused = !paused
			get_tree().paused = paused
			$GUI/Paused.visible = paused
	
	if paused or !can_pause:
		return
	
	if event.is_action_pressed("action-top-1"):
		if char_lanes["apollo"]["current"] != "top":
			apollo_afterimage_effect()
			char_lanes["apollo"]["current"] = "top"
			apollo.position.x = char_lanes["apollo"]["top"]
			apollo_animtree.get("parameters/playback").travel("Teleport")
		else:
			apollo_animtree.get("parameters/playback").travel("Hit")
		if canhit["d_top"].size() > 0:
			var note = canhit["d_top"].pop_front()
			note_on_hit(note)
	elif event.is_action_pressed("action-bottom-1"):
		if char_lanes["apollo"]["current"] != "bottom":
			apollo_afterimage_effect()
			char_lanes["apollo"]["current"] = "bottom"
			apollo.position.x = char_lanes["apollo"]["bottom"]
			apollo_animtree.get("parameters/playback").travel("Teleport")
		else:
			apollo_animtree.get("parameters/playback").travel("Hit")
		if canhit["d_bottom"].size() > 0:
			var note = canhit["d_bottom"].pop_front()
			note_on_hit(note)
	elif event.is_action_pressed("action-left-1"):
		if char_lanes["apollo"]["current"] != "left":
			apollo_afterimage_effect()
			char_lanes["apollo"]["current"] = "left"
			apollo.position.x = char_lanes["apollo"]["left"]
			apollo_animtree.get("parameters/playback").travel("Teleport")
		else:
			apollo_animtree.get("parameters/playback").travel("Hit")
		if canhit["d_left"].size() > 0:
			var note = canhit["d_left"].pop_front()
			note_on_hit(note)
	elif event.is_action_pressed("action-right-1"): 
		if char_lanes["apollo"]["current"] != "right":
			apollo_afterimage_effect()
			char_lanes["apollo"]["current"] = "right"
			apollo.position.x = char_lanes["apollo"]["right"]
			apollo_animtree.get("parameters/playback").travel("Teleport")
		else:
			apollo_animtree.get("parameters/playback").travel("Hit")
		if canhit["d_right"].size() > 0:
			var note = canhit["d_right"].pop_front()
			note_on_hit(note)
	
	if event.is_action_pressed("left") or event.is_action_pressed("right"):
		if artemis_tween and artemis_tween.is_running():
			artemis_tween.kill()
		artemis_tween = get_tree().create_tween()
		artemis_tween.tween_property(self, "artemis_boost_speed", artemis_move_speed, 0.2).set_trans(Tween.TRANS_SINE)
		artemis_tween.tween_callback(
			func():
				artemis_boost_speed = artemis_move_speed
		)
	elif event.is_action_released("left") or event.is_action_released("right"):
		if artemis_tween:
			artemis_tween.kill()
		if char_lanes["artemis"]["current"] != "left" and char_lanes["artemis"]["current"] != "right":
			artemis_boost_speed = artemis_initial_speed

func _process(delta):
	var progress_ratio = $GUI/HUD/Score/Bar.value / $GUI/HUD/Score/Bar.max_value
	$GUI/HUD/Score/Glow.position.x = -1498 + $GUI/HUD/Score/Bar.size.x * progress_ratio
	Core.data["current_score"] = base_score + notes_score
	$GUI/HUD/Score/Bar.value = snapped(Core.data["current_score"], 1)
	$GUI/HUD/SoloScore/Text.text = str("%07d" % snapped(Core.data["current_score"], 1))
	$GUI/HUD/SoloScore2/Text.text = str("%07d" % snapped(Core.data["current_score"], 1))
	$GUI/HUD/Score/Upper/Score.text = str("%07d" % snapped(Core.data["current_score"], 1))
	if can_pause:
		if Input.is_action_pressed("left"):
			if artemis.position.x < -9:
				artemis.position.x = lerp(artemis.position.x, artemis.position.x + 0.1 * artemis_boost_speed, delta * artemis_move_speed)
		if Input.is_action_pressed("right"):
			if artemis.position.x > -33:
				artemis.position.x = lerp(artemis.position.x, artemis.position.x - 0.1 * artemis_boost_speed, delta * artemis_move_speed)
		
		if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
			var to_left = abs(artemis.position.x - char_lanes["artemis"]["left"])
			var to_top = abs(artemis.position.x - char_lanes["artemis"]["top"])
			var to_bottom = abs(artemis.position.x - char_lanes["artemis"]["bottom"])
			var to_right = abs(artemis.position.x - char_lanes["artemis"]["right"])
			var closest_pos = min(to_left, to_top, to_bottom, to_right)
			var target_x
			if closest_pos == to_left:
				target_x = char_lanes["artemis"]["left"]
			elif closest_pos == to_top:
				target_x = char_lanes["artemis"]["top"]
			elif closest_pos == to_bottom:
				target_x = char_lanes["artemis"]["bottom"]
			elif closest_pos == to_right:
				target_x = char_lanes["artemis"]["right"]
			artemis.position.x = lerp(artemis.position.x, float(target_x), delta * artemis_move_speed)

func _on_settings_pressed():
	if can_pause:
		paused = !paused
		get_tree().paused = paused
		$GUI/Paused.visible = paused

func _on_unpause_pressed():
	paused = false
	get_tree().paused = paused
	$GUI/Paused.visible = paused

func _on_restart_pressed():
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Restart")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		_ready()
	)

func _on_exit_pressed():
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_return_pressed():
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_retry_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Restart")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		_ready()
	)

func _on_music_finished():
	Core.cooldown(2, func():
		loading(false)
		can_pause = false
		Core.data["current_score"] = snapped(Core.data["current_score"], 1)
		$GUI/End/Score.text = str(Core.data["current_score"])
		if DataEngine.save_info["high_scores"].has(song_name):
			if Core.data["current_score"] > DataEngine.save_info["high_scores"][song_name]:
				DataEngine.save_info["high_scores"][song_name] = Core.data["current_score"]
				$GUI/End/NewHighScore.visible = true
			else:
				$GUI/End/NewHighScore.visible = false
		else:
			DataEngine.save_info["high_scores"][song_name] = Core.data["current_score"]
		$GUI/End/HighScore.text = "HIGH SCORE: " + str(DataEngine.save_info["high_scores"][song_name])
		DataEngine.save_data()
		Core.cooldown(1, func():
			$GUI/End.visible = true
			$GUI/HUD.visible = false
			loading(true)
		)
	)
