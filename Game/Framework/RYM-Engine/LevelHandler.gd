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

@export var map_speed : int = 30
@export var channel_midi : int = 1
@export var spawn_distance : int = 100

@export var initial_delay : float = 4.0
@export var wav_delay : float = 6.0
@export var music_first : bool = false

var delta_stellar = 0.05
var delta_great = 0.05
var delta_good = 0.05
var delta_bad = 0.05
var delta_miss = 0.1
var hit_delta = delta_stellar + delta_great + delta_good + delta_bad + delta_miss

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

var artemis_enabled = true
var artemis_tween
var artemis_boost_speed = 50.0
var artemis_move_speed = 15.0
var artemis_initial_speed = artemis_boost_speed

var paused = false
var can_pause = false

func get_lane(direction):
	if direction == "d_left":
		return d_lane_left
	elif direction == "d_top":
		return d_lane_top
	elif direction == "d_bottom":
		return d_lane_bottom
	elif direction == "d_right":
		return d_lane_right

func _ready():
	var anim = anim_player.get_animation("Playing")
	var tmain_pos = anim.find_track("Main:position", 0)
	var kmain_pos = anim.track_find_key(tmain_pos, 600.0, true)
	anim.track_set_key_value(tmain_pos, kmain_pos, Vector3(0, 0, 600.0 * map_speed))
	
	var tloading = anim.find_track("GUI/Loading:color", 0)
	anim.track_insert_key(tloading, music_length - 1 + initial_delay + 2, Color.TRANSPARENT)
	anim.track_insert_key(tloading, music_length + initial_delay + 2, Color.BLACK)
	
	var tcam_pos = anim.find_track("Camera3D:position", 0)
	var kcam_pos = anim.track_find_key(tcam_pos, 4.0, true)
	if Core.data["apollo"] and Core.data["artemis"]:
		apollo.position = Vector3(3, -2, 0)
		artemis.position = Vector3(-3, -2, 0)
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
		apollo.position = Vector3(0, -2, 0)
		artemis.visible = false
		artemis_v.visible = false
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
		artemis.position = Vector3(0, -2, 0)
		apollo.visible = false
		apollo_v.visible = false
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
	
	anim_tree.active = true
	if music_first:
		Core.cooldown(initial_delay, func():
			can_pause = true
			animate_bar()
			score_timer.start()
			music.play()
			Core.cooldown(wav_delay - 2, func():
				midi.play()
			)
		)
	else:
		Core.cooldown(initial_delay, func():
			can_pause = true
			animate_bar()
			score_timer.start()
			midi.play()
			Core.cooldown(2, func():
				music.play()
			)
		)

func animate_bar():
	$GUI/HUD/Score/Bar.value = 0
	var tween = get_tree().create_tween()
	tween.tween_property(
		$GUI/HUD/Score/Bar, 
		"value", 
		100000, 
		music_length
	)

func _on_note_event(channel, event):
	if event.type == SMF.MIDIEventType.note_on:
		if channel.number == channel_midi - 1: 
			if event.note in mapping.keys():
				# SPAWN
				var note_direction = mapping[event.note]
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
	elif note.get_node_or_null("Good"):
		note.get_node("Indicator").mesh.material.albedo_texture = good_texture
	elif note.get_node_or_null("Bad"):
		note.get_node("Indicator").mesh.material.albedo_texture = bad_texture
	elif note.get_node_or_null("Stellar"):
		note.get_node("Indicator").mesh.material.albedo_texture = stellar_texture
	elif note.get_node_or_null("Miss"):
		note.get_node("Indicator").mesh.material.albedo_texture = miss_texture

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
	elif event.is_action_pressed("escape"):
		if can_pause:
			paused = !paused
			get_tree().paused = paused
			$GUI/Paused.visible = paused
	
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
		artemis_tween.kill()
		if char_lanes["artemis"]["current"] != "left" and char_lanes["artemis"]["current"] != "right":
			artemis_boost_speed = artemis_initial_speed

func _process(delta):
	var progress_ratio = $GUI/HUD/Score/Bar.value / $GUI/HUD/Score/Bar.max_value
	$GUI/HUD/Score/Glow.position.x = -1498 + $GUI/HUD/Score/Bar.size.x * progress_ratio
	if artemis_enabled:
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

func _on_score_timeout():
	if can_pause:
		Core.data["current_score"] += (500000 / music_length) / 500
		$GUI/HUD/SoloScore/Text.text = str("%07d" % snapped(Core.data["current_score"], 1))
		$GUI/HUD/Score/Upper/Score.text = str("%07d" % snapped(Core.data["current_score"], 1))

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
	state_machine.travel("Return")
	can_pause = false
	Core.cooldown(0.5, func():
		_ready()
	)

func _on_exit_pressed():
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Return")
	can_pause = false
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_return_pressed():
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Return")
	can_pause = false
	Core.cooldown(0.5, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_retry_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Return")
	Core.cooldown(0.5, func():
		_ready()
	)
