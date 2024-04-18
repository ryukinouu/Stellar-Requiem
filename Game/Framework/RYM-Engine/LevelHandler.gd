extends Node3D

@onready var midi = $Midi
@onready var music = $Main/Camera3D/Music
@onready var sfx = $Main/Camera3D/SFX
@onready var misc = $Main/Misc

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

@onready var notes_lanes = $Main/Notes
@onready var d_lane_left = $Main/Notes/d_left
@onready var d_lane_top = $Main/Notes/d_top
@onready var d_lane_bottom = $Main/Notes/d_bottom
@onready var d_lane_right = $Main/Notes/d_right
@onready var g_lane_left = $Main/Notes/g_left
@onready var g_lane_top = $Main/Notes/g_top
@onready var g_lane_bottom = $Main/Notes/g_bottom
@onready var g_lane_right = $Main/Notes/g_right

@onready var apollo = $Main/Apollo
@onready var apollo_animtree = $Main/Apollo/AnimationTree
@onready var artemis = $Main/Artemis
@onready var artemis_animtree = $Main/Artemis/AnimationTree

@onready var apollo_v = $"Main/Player1-Visuals"
@onready var artemis_v = $"Main/Player2-Visuals"

@onready var score_timer = $Score

@onready var music_length = music.stream.get_length()

@export var song_name : String = "Music Box"
@export var map_speed : int = 30
@export var channel_midi : int = 1
@export var spawn_distance : int = 100

@export var drum_notes : int = 110
@export var guitar_notes : int = 110

@export var initial_delay : float = 4.0
@export var wav_delay : float = 6.0
@export var music_first : bool = false

var green_note_scene = load("res://Game/Scenes/Notes/GreenNote.tscn")
var red_note_scene = load("res://Game/Scenes/Notes/RedNote.tscn")
var yellow_note_scene = load("res://Game/Scenes/Notes/YellowNote.tscn")
var blue_note_scene = load("res://Game/Scenes/Notes/BlueNote.tscn")
var hover_note_scene = load("res://Game/Scenes/Notes/HoverNote.tscn")
var bomb_note_scene = load("res://Game/Scenes/Notes/BombNote.tscn")
var rocks_scene = load("res://Game/Scenes/Notes/Rocks.tscn")

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
	41: "d_right",
	
	12: "g_left",
	19: "g_top",
	24: "g_bottom",
	31: "g_right",
	
	13: "g_left",
	20: "g_top",
	25: "g_bottom",
	32: "g_right",
	
	14: "g_left",
	21: "g_top",
	26: "g_bottom",
	33: "g_right",
	
	15: "g_left",
	22: "g_top",
	27: "g_bottom",
	34: "g_right"
}
var canhit = {
	"d_left": [], 
	"d_top": [], 
	"d_bottom": [], 
	"d_right": [],
	"g_left": {
		"green": [],
		"red": [],
		"hover": [],
		"rocks": []
	},
	"g_top": {
		"green": [],
		"red": [],
		"hover": [],
		"rocks": []
	},
	"g_bottom": {
		"green": [],
		"red": [],
		"hover": [],
		"rocks": []
	},
	"g_right": {
		"green": [],
		"red": [],
		"hover": [],
		"rocks": []
	}
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
		"right": -33
	},
}

var level_seed = str(drum_notes) + str(guitar_notes)
var apollo_bomb_percentage = 0.5
var apollo_bomb_positions
var apollo_curr_note_num
var artemis_tween

var delta_stellar = 0.1
var delta_great = 0.05
var delta_good = 0.05
var delta_bad = 0.05
var delta_miss = 0.075
var hit_delta = delta_stellar + delta_great + delta_good + delta_bad + delta_miss

var paused = false
var can_pause = false
var apollo_notes_disabled = false
var artemis_notes_disabled = false
var total_notes = 0
var base_score = 0
var notes_score = 0

# Apollo Score
var apollo_total_notes = 0
var apollo_base_score = 0
var apollo_notes_score = 0

# Artemis Score
var artemis_total_notes = 0
var artemis_base_score = 0
var artemis_notes_score = 0

var base_score_tween
var apollo_score_tween
var artemis_score_tween

func get_lane(direction):
	if direction == "d_left":
		return d_lane_left
	elif direction == "d_top":
		return d_lane_top
	elif direction == "d_bottom":
		return d_lane_bottom
	elif direction == "d_right":
		return d_lane_right
	elif direction == "g_left":
		return g_lane_left
	elif direction == "g_top":
		return g_lane_top
	elif direction == "g_bottom":
		return g_lane_bottom
	elif direction == "g_right":
		return g_lane_right

func generate_bomb_positions(min_val, max_val, num):
	var rng = RandomNumberGenerator.new()
	rng.seed = int(level_seed)
	assert(max_val - min_val + 1 >= num)
	var positions = []
	for i in range(min_val, max_val):
		positions.append(i)
	positions.shuffle()
	return positions.slice(0, num - 1)

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
	song_name = Core.scene_data["song_name"]
	map_speed = Core.scene_data["map_speed"]
	drum_notes = Core.scene_data["drum_notes"]
	guitar_notes = Core.scene_data["guitar_notes"]
	music_first = Core.scene_data["music_first"]
	wav_delay = Core.scene_data["wav_delay"]
	music.stream = Core.scene_data["wav"]
	midi.file = Core.scene_data["midi"]
	$WorldEnvironment.environment.adjustment_brightness = Core.data["settings"]["brightness"]
	music.volume_db = Core.data["settings"]["music-volume"]
	sfx.volume_db = Core.data["settings"]["sfx-volume"]
	Core.data["g_lives"] = 3
	Core.data["d_lives"] = 3
	Core.save_state("")
	var file = FileAccess.open("res://Game/Framework/RYM-Engine/bomb_positions.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		Core.apollo_bomb_note_positions = JSON.parse_string(json_text)
		if Core.apollo_bomb_note_positions != null:
			print("Data loaded successfully!")
		else:
			print("Failed to parse JSON.")
	else:
		print("Failed to open file for reading.")

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
	$GUI/HUD/Score/Upper/Score.text = "0000000"
	$GUI/Paused.visible = false
	$GUI/HUD/Score/Bar.value = 0
	
	delete_last_run()
	if base_score_tween:
		base_score_tween.kill()
	if apollo_score_tween:
		apollo_score_tween.kill()
	if artemis_score_tween:
		artemis_score_tween.kill()
	
	$GUI/HUD/ApolloScore/Score.text = "0000000"
	$GUI/HUD/ArtemisScore/Score.text = "0000000"
	base_score = 0
	notes_score = 0
	apollo_base_score = 0
	apollo_notes_score = 0
	artemis_base_score = 0
	artemis_notes_score = 0
	
	if Core.scene_data["song_name"] not in Core.apollo_bomb_note_positions:
		apollo_bomb_positions = generate_bomb_positions(1, drum_notes, drum_notes * apollo_bomb_percentage)
		Core.apollo_bomb_note_positions[Core.scene_data["song_name"]] = apollo_bomb_positions
	else:
		apollo_bomb_positions = Core.apollo_bomb_note_positions[Core.scene_data["song_name"]]
	apollo_curr_note_num = 0
	
	if Core.data["apollo"] and Core.data["artemis"]:
		total_notes = guitar_notes + drum_notes
		apollo.position = Vector3(3, -2, 0)
		artemis.position = Vector3(-3, -2, 0)
		
		apollo_notes_disabled = false
		artemis_notes_disabled = false
		$GUI/HUD/Score/Upper/Score.visible = true
		$GUI/HUD/ApolloScore.visible = true
		$GUI/HUD/ApolloSide.visible = true
		$GUI/HUD/Score/Upper/Apollo.visible = true
		$GUI/HUD/ArtemisScore.visible = true
		$GUI/HUD/ArtemisSide.visible = true
		$GUI/HUD/ArtemisScore.position.y = 528
		$GUI/HUD/ApolloScore.position.y = 528
		$GUI/HUD/Score/Upper/Artemis.visible = true
		$GUI/HUD/ApolloSide/Lives/One.visible = true
		$GUI/HUD/ApolloSide/Lives/Two.visible = true
		$GUI/HUD/ApolloSide/Lives/Three.visible = true
		$GUI/HUD/ArtemisSide/Lives/One.visible = true
		$GUI/HUD/ArtemisSide/Lives/Two.visible = true
		$GUI/HUD/ArtemisSide/Lives/Three.visible = true
		$GUI/End/ApolloScoreHeader.visible = true
		$GUI/End/ApolloScore.visible = true
		$GUI/End/ArtemisScoreHeader.visible = true
		$GUI/End/ArtemisScore.visible = true
		
		anim.track_set_key_value(tcam_pos, kcam_pos, Vector3(0, 25, -20))
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
		$GUI/HUD/ApolloScore.visible = false
		$GUI/HUD/ApolloSide.visible = true
		$GUI/HUD/Score/Upper/Apollo.visible = true
		$GUI/HUD/ArtemisScore.visible = true
		$GUI/HUD/ArtemisSide.visible = false
		$GUI/HUD/ArtemisScore.position.y = 578
		$GUI/HUD/ApolloScore.position.y = 578
		$GUI/HUD/Score/Upper/Artemis.visible = false
		$GUI/HUD/ApolloSide/Lives/One.visible = true
		$GUI/HUD/ApolloSide/Lives/Two.visible = true
		$GUI/HUD/ApolloSide/Lives/Three.visible = true
		$GUI/HUD/ArtemisSide/Lives/One.visible = false
		$GUI/HUD/ArtemisSide/Lives/Two.visible = false
		$GUI/HUD/ArtemisSide/Lives/Three.visible = false
		$GUI/End/ApolloScoreHeader.visible = false
		$GUI/End/ApolloScore.visible = false
		$GUI/End/ArtemisScoreHeader.visible = false
		$GUI/End/ArtemisScore.visible = false
		
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
		$GUI/HUD/ApolloScore.visible = true
		$GUI/HUD/ApolloSide.visible = false
		$GUI/HUD/Score/Upper/Apollo.visible = false
		$GUI/HUD/ArtemisScore.visible = false
		$GUI/HUD/ArtemisSide.visible = true
		$GUI/HUD/Score/Upper/Artemis.visible = true
		$GUI/HUD/ArtemisScore.position.y = 578
		$GUI/HUD/ApolloScore.position.y = 578
		$GUI/HUD/ApolloSide/Lives/One.visible = false
		$GUI/HUD/ApolloSide/Lives/Two.visible = false
		$GUI/HUD/ApolloSide/Lives/Three.visible = false
		$GUI/HUD/ArtemisSide/Lives/One.visible = true
		$GUI/HUD/ArtemisSide/Lives/Two.visible = true
		$GUI/HUD/ArtemisSide/Lives/Three.visible = true
		$GUI/End/ApolloScoreHeader.visible = false
		$GUI/End/ApolloScore.visible = false
		$GUI/End/ArtemisScoreHeader.visible = false
		$GUI/End/ArtemisScore.visible = false
		
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
			Core.cooldown(1.8, func():
				music.play()
			)
		)

func begin_song():
	paused = false
	var tween = get_tree().create_tween()
	tween.tween_property(
		$GUI/HUD/Score/SongProgress, 
		"value", 
		1000000, 
		music_length
	)
	base_score_tween = get_tree().create_tween()
	base_score_tween.tween_property(
		self, 
		"base_score", 
		500000, 
		music_length
	)
	apollo_score_tween = get_tree().create_tween()
	apollo_score_tween.tween_property(
		self, 
		"apollo_base_score", 
		250000, 
		music_length
	)
	artemis_score_tween = get_tree().create_tween()
	artemis_score_tween.tween_property(
		self, 
		"artemis_base_score", 
		250000, 
		music_length
	)

func _on_note_event(channel, event):
	if event.type == SMF.MIDIEventType.note_on:
		if channel.number == channel_midi - 1: 
			if event.note in mapping.keys():
				# SPAWN
				var note_direction = mapping[event.note]
				var note_scene
				if note_direction.substr(0, 2) == "d_":
					if apollo_notes_disabled:
						return
					apollo_curr_note_num += 1

					if event.note == 36:
						note_scene = red_note_scene
					elif event.note == 38:
						note_scene = yellow_note_scene
					elif event.note == 40:
						note_scene = blue_note_scene
					elif event.note == 41:
						note_scene = green_note_scene

					var curr_row
					if typeof(apollo_curr_note_num) != typeof(apollo_bomb_positions[0]):
						curr_row = float(apollo_curr_note_num)
					else:
						curr_row = apollo_curr_note_num

					if curr_row in apollo_bomb_positions:
						var pos_bomb_directions = ["d_left", "d_top", "d_bottom", "d_right"]
						pos_bomb_directions.erase(mapping[event.note])
						var bomb_direction = pos_bomb_directions[randi() % 3]
						var bomb_instance = rocks_scene.instantiate()

						var mesh_instance = bomb_instance.get_node("Rocks")
						if mesh_instance and mesh_instance is MeshInstance3D:
							var mesh = mesh_instance.mesh
							if mesh:
								for surface in range(mesh.get_surface_count()):
									var mat = mesh.surface_get_material(surface)
									if mat:
										var new_mat = mat.duplicate()
										mesh.surface_set_material(surface, new_mat)

						get_lane(bomb_direction).add_child(bomb_instance)
						bomb_instance.position.z = spawn_distance

						var tween = get_tree().create_tween()
						tween.tween_property(
							bomb_instance, 
							"position:z", 
							-spawn_distance, 
							2 * 2
						)
						tween.tween_callback(bomb_instance.queue_free)

						Core.cooldown(2, func():
							if char_lanes["apollo"]["current"] == bomb_direction.substr(2, bomb_direction.length() - 1):
								Core.data["d_lives"] -= 1
								Core.sound_effect(sfx, "lose-life")
								if Core.data["d_lives"] == 0:
									tween = get_tree().create_tween()
									tween.tween_property(
										music, 
										"pitch_scale", 
										0, 
										1
									)
									tween.tween_callback(func():
										music.pitch_scale = 1
										music.stop()
									)
									on_game_over()
									Core.sound_effect(sfx, "game-over")
						)

				elif note_direction.substr(0, 2) == "g_":
					if artemis_notes_disabled:
						return

					if event.note == 12 or event.note == 19 or event.note == 24 or event.note == 31:
						note_scene = green_note_scene
					elif event.note == 13 or event.note == 20 or event.note == 25 or event.note == 32:
						note_scene = red_note_scene
					elif event.note == 14 or event.note == 21 or event.note == 26 or event.note == 33:
						note_scene = hover_note_scene
					elif event.note == 15 or event.note == 22 or event.note == 27 or event.note == 34:
						note_scene = rocks_scene

				var note_instance = note_scene.instantiate()
				if note_scene != rocks_scene:
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
				else:
					var mesh_instance = note_instance.get_node("Rocks")
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
				
				if note_scene == hover_note_scene:
					Core.cooldown(2, func():
						if char_lanes["artemis"]["current"] == note_direction.substr(2, note_direction.length() - 1):
							change_indicator(note_instance, "Miss", "Stellar")
						#Core.sound_effect(sfx, "artemis-hit")
						artemis_animtree.get("parameters/playback").travel("Hit_003")
						tweens[note_instance] = tween
						note_on_hit(note_instance, "Artemis")
					)
				elif note_scene == rocks_scene:
					Core.cooldown(2, func():
						if char_lanes["artemis"]["current"] == note_direction.substr(2, note_direction.length() - 1):
							Core.data["g_lives"] -= 1
							Core.sound_effect(sfx, "lose-life")
							if Core.data["g_lives"] == 0:
								tween = get_tree().create_tween()
								tween.tween_property(
									music, 
									"pitch_scale", 
									0, 
									1
								)
								tween.tween_callback(func():
									music.pitch_scale = 1
									music.stop()
								)
								on_game_over()
								Core.sound_effect(sfx, "game-over")
					)
				else:
					# HIT WINDOW
					Core.cooldown(2 - hit_delta, func():
						var note_color = null
						if event.note <= 34:
							note_color = get_note_color(event.note)
							canhit[note_direction][note_color].append(note_instance)
						else:
							canhit[note_direction].append(note_instance)
						tweens[note_instance] = tween
						Core.cooldown(hit_delta + delta_miss, func():
							if note_instance in canhit[mapping[event.note]]:
								canhit[mapping[event.note]].erase(note_instance)
								tweens.erase(note_instance)
							elif note_color != null and note_instance in canhit[mapping[event.note]][note_color]:
								canhit[mapping[event.note]][note_color].erase(note_instance)
								tweens.erase(note_instance)
						)
					)
				
				if note_scene != hover_note_scene and note_scene != rocks_scene:
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
											change_indicator(note_instance, "Stellar", "Good")
											Core.cooldown(delta_good, func():
												change_indicator(note_instance, "Good", "Miss")
											)
										)
									)
								)
							)
						)
					)

func delete_last_run():
	Core.erase_all_timers()
	for lane in notes_lanes.get_children():
		for visual in lane.get_children():
			visual.free()

func get_note_color(note):
	if note == 12 or note == 19 or note == 24 or note == 31:
		return "green"
	elif note == 13 or note == 20 or note == 25 or note == 32:
		return "red"
	elif note == 14 or note == 21 or note == 26 or note == 33:
		return "hover"
	elif note == 15 or note == 22 or note == 27 or note == 34:
		return "rocks"

func change_indicator(note, old, new):
	if note:
		note.get_node(old).name = new

func note_on_hit(note, player):
	if !note:
		return
	var anim_tree = note.get_node("AnimationTree")
	var anim_player = note.get_node("AnimationPlayer")
	var anim = anim_tree.get("parameters/playback")
	anim.travel("hit")
	tweens[note].kill()
	Core.cooldown(anim_player.get_animation("hit").length, note.queue_free)
	if note.get_node_or_null("Great"):
		note.get_node("Indicator").mesh.material.albedo_texture = great_texture
		notes_score += note_values["great"]
		if player == "Apollo":
			apollo_notes_score += note_values["great"]
		else:
			artemis_notes_score += note_values["great"]
	elif note.get_node_or_null("Good"):
		note.get_node("Indicator").mesh.material.albedo_texture = good_texture
		notes_score += note_values["good"]
		if player == "Apollo":
			apollo_notes_score += note_values["good"]
		else:
			artemis_notes_score += note_values["good"]
	elif note.get_node_or_null("Bad"):
		note.get_node("Indicator").mesh.material.albedo_texture = bad_texture
		notes_score += note_values["bad"]
		if player == "Apollo":
			apollo_notes_score += note_values["bad"]
		else:
			artemis_notes_score += note_values["bad"]
	elif note.get_node_or_null("Stellar"):
		note.get_node("Indicator").mesh.material.albedo_texture = stellar_texture
		notes_score += note_values["stellar"]
		if player == "Apollo":
			apollo_notes_score += note_values["stellar"]
		else:
			artemis_notes_score += note_values["stellar"]
	elif note.get_node_or_null("Miss"):
		note.get_node("Indicator").mesh.material.albedo_texture = miss_texture
		notes_score += note_values["miss"]
		if player == "Apollo":
			apollo_notes_score += note_values["miss"]
		else:
			artemis_notes_score += note_values["miss"]

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
	
	# Apollo Movement/Action Buttons
	if !apollo_notes_disabled:
		if event.is_action_pressed("apollo-top"):
			Core.sound_effect(sfx, "apollo-move")
			if char_lanes["apollo"]["current"] != "top":
				apollo_afterimage_effect()
				char_lanes["apollo"]["current"] = "top"
				apollo.position.x = char_lanes["apollo"]["top"]
				apollo_animtree.get("parameters/playback").travel("Teleport")
			else:
				apollo_animtree.get("parameters/playback").travel("Hit")
			if canhit["d_top"].size() > 0:
					#Core.sound_effect(sfx, "apollo-hit")
				var note = canhit["d_top"].pop_front()
				note_on_hit(note, "Apollo")
		elif event.is_action_pressed("apollo-bottom"):
			Core.sound_effect(sfx, "apollo-move")
			if char_lanes["apollo"]["current"] != "bottom":
				apollo_afterimage_effect()
				char_lanes["apollo"]["current"] = "bottom"
				apollo.position.x = char_lanes["apollo"]["bottom"]
				apollo_animtree.get("parameters/playback").travel("Teleport")
			else:
				apollo_animtree.get("parameters/playback").travel("Hit")
			if canhit["d_bottom"].size() > 0:
					#Core.sound_effect(sfx, "apollo-hit")
				var note = canhit["d_bottom"].pop_front()
				note_on_hit(note, "Apollo")
		elif event.is_action_pressed("apollo-left"):
			Core.sound_effect(sfx, "apollo-move")
			if char_lanes["apollo"]["current"] != "left":
				apollo_afterimage_effect()
				char_lanes["apollo"]["current"] = "left"
				apollo.position.x = char_lanes["apollo"]["left"]
				apollo_animtree.get("parameters/playback").travel("Teleport")
			else:
				apollo_animtree.get("parameters/playback").travel("Hit")
			if canhit["d_left"].size() > 0:
					#Core.sound_effect(sfx, "apollo-hit")
				var note = canhit["d_left"].pop_front()
				note_on_hit(note, "Apollo")
		elif event.is_action_pressed("apollo-right"): 
			Core.sound_effect(sfx, "apollo-move")
			if char_lanes["apollo"]["current"] != "right":
				apollo_afterimage_effect()
				char_lanes["apollo"]["current"] = "right"
				apollo.position.x = char_lanes["apollo"]["right"]
				apollo_animtree.get("parameters/playback").travel("Teleport")
			else:
				apollo_animtree.get("parameters/playback").travel("Hit")
			if canhit["d_right"].size() > 0:
				#Core.sound_effect(sfx, "apollo-hit")
				var note = canhit["d_right"].pop_front()
				note_on_hit(note, "Apollo")

	# Artemis Single Movement
	if !artemis_notes_disabled:
		if event.is_action_pressed("artemis-left"):
			Core.sound_effect(sfx, "artemis-moveleft")
			var next_pos = get_next_lane("left")
			if artemis_tween and artemis_tween.is_running():
				artemis_tween.kill()
			artemis_tween = get_tree().create_tween()
			artemis_tween.tween_property(
				artemis,
				"position:x", 
				next_pos, 
				0.2
			).set_trans(Tween.TRANS_SINE)
			artemis_animtree.get("parameters/playback").travel("Tilt_L")
		elif event.is_action_pressed("artemis-right"):
			Core.sound_effect(sfx, "artemis-moveright")
			var next_pos = get_next_lane("right")
			if artemis_tween and artemis_tween.is_running():
				artemis_tween.kill()
			artemis_tween = get_tree().create_tween()
			artemis_tween.tween_property(
				artemis,
				"position:x", 
				next_pos, 
				0.2
			).set_trans(Tween.TRANS_SINE)
			artemis_animtree.get("parameters/playback").travel("Tilt_R")
		
		if event.is_action_pressed("artemis-green"):
			var curr_lane = get_curr_canhit_lane()
			artemis_animtree.get("parameters/playback").travel("Hit_001")
			if canhit[curr_lane]["green"].size() > 0:
				#Core.sound_effect(sfx, "artemis-hit")
				var note = canhit[curr_lane]["green"].pop_front()
				note_on_hit(note, "Artemis")
		elif event.is_action_pressed("artemis-red"):
			var curr_lane = get_curr_canhit_lane()
			artemis_animtree.get("parameters/playback").travel("Hit_002")
			if canhit[curr_lane]["red"].size() > 0:
				#Core.sound_effect(sfx, "artemis-hit")
				var note = canhit[curr_lane]["red"].pop_front()
				note_on_hit(note, "Artemis")
		elif event.is_action_released("artemis-green") or event.is_action_released("artemis-red"):
			artemis_animtree.get("parameters/playback").travel("Forward")

func get_next_lane(direction):
	var curr_lane = char_lanes["artemis"]["current"]
	if direction == "left":
		if curr_lane == "left":
			char_lanes["artemis"]["current"] = "left"
		elif curr_lane == "top":
			char_lanes["artemis"]["current"] = "left"
		elif curr_lane == "bottom":
			char_lanes["artemis"]["current"] = "top"
		elif curr_lane == "right":
			char_lanes["artemis"]["current"] = "bottom"
	elif direction == "right":
		if curr_lane == "left":
			char_lanes["artemis"]["current"] = "top"
		elif curr_lane == "top":
			char_lanes["artemis"]["current"] = "bottom"
		elif curr_lane == "bottom":
			char_lanes["artemis"]["current"] = "right"
		elif curr_lane == "right":
			char_lanes["artemis"]["current"] = "right"
	return char_lanes["artemis"][char_lanes["artemis"]["current"]]

func get_curr_canhit_lane():
	var curr_lane = char_lanes["artemis"]["current"]
	if curr_lane == "left":
		return "g_left"
	elif curr_lane == "top":
		return "g_top"
	elif curr_lane == "bottom":
		return "g_bottom"
	elif curr_lane == "right":
		return "g_right"
	return "Error"

func _process(delta):
	var progress_ratio = $GUI/HUD/Score/Bar.value / $GUI/HUD/Score/Bar.max_value
	$GUI/HUD/Score/Glow.position.x = -1498 + $GUI/HUD/Score/Bar.size.x * progress_ratio
	
	Core.data["current_score"] = base_score + notes_score
	Core.data["apollo_current_score"] = apollo_base_score + apollo_notes_score
	Core.data["artemis_current_score"] = artemis_base_score + artemis_notes_score
	
	$GUI/HUD/Score/Bar.value = snapped(Core.data["current_score"], 1)
	$GUI/HUD/Score/Upper/Score.text = str("%07d" % snapped(Core.data["current_score"], 1))
	if !Core.data["apollo"] or !Core.data["artemis"]:
		$GUI/HUD/ApolloScore/Score.text = str("%07d" % snapped(Core.data["current_score"], 1))
		$GUI/HUD/ArtemisScore/Score.text = str("%07d" % snapped(Core.data["current_score"], 1))
	else:
		$GUI/HUD/ApolloScore/Score.text = str("%07d" % snapped(Core.data["apollo_current_score"], 1))
		$GUI/HUD/ArtemisScore/Score.text = str("%07d" % snapped(Core.data["artemis_current_score"], 1))
	
	if Core.data["g_lives"] == 2:
		$GUI/HUD/ArtemisSide/Lives/Three.visible = false
	elif Core.data["g_lives"] == 1:
		$GUI/HUD/ArtemisSide/Lives/Two.visible = false
	elif Core.data["g_lives"] == 0:
		$GUI/HUD/ArtemisSide/Lives/One.visible = false
		
	if Core.data["d_lives"] == 2:
		$GUI/HUD/ApolloSide/Lives/Three.visible = false
	elif Core.data["d_lives"] == 1:
		$GUI/HUD/ApolloSide/Lives/Two.visible = false
	elif Core.data["d_lives"] == 0:
		$GUI/HUD/ApolloSide/Lives/One.visible = false

func _on_pause_pressed():
	paused = true
	Core.pause_all_timers()
	get_tree().paused = paused
	$GUI/Paused.visible = paused

func _on_unpause_pressed():
	paused = false
	Core.resume_all_timers()
	get_tree().paused = paused
	$GUI/Paused.visible = paused

func _on_settings_pressed():
	Core.save_bomb_positions()
	if can_pause:
		Core.save_state(get_tree().current_scene.scene_file_path)
		
		paused = !paused
		get_tree().paused = paused
		$GUI/Paused.visible = false
		var state_machine = anim_tree.get("parameters/playback")
		can_pause = false
		loading(false)
		Core.cooldown(1, func():
			get_tree().change_scene_to_file("res://Game/Scenes/Menu/Settings.tscn")
		)

func _on_restart_pressed():
	Core.save_bomb_positions()
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Restart")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		_ready()
	)

func _on_exit_pressed():
	Core.save_bomb_positions()
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_return_pressed():
	Core.save_bomb_positions()
	get_tree().paused = false
	var state_machine = anim_tree.get("parameters/playback")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")
	)

func _on_retry_pressed():
	Core.save_bomb_positions()
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("Restart")
	can_pause = false
	loading(false)
	Core.cooldown(1, func():
		_ready()
	)

func on_game_over():
	Core.save_bomb_positions()
	loading(false)
	can_pause = false
	midi.stop()
	Core.data["current_score"] = snapped(Core.data["current_score"], 1)
	Core.data["apollo_current_score"] = snapped(Core.data["apollo_current_score"], 1)
	Core.data["artemis_current_score"] = snapped(Core.data["artemis_current_score"], 1)
	$GUI/End/Score.text = str(Core.data["current_score"])
	$GUI/End/ApolloScore.text = str(Core.data["apollo_current_score"])
	$GUI/End/ArtemisScore.text = str(Core.data["artemis_current_score"])
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

func _on_music_finished():
	Core.sound_effect(sfx, "song-complete")
	Core.cooldown(0.2, func():
		Core.save_bomb_positions()
		loading(false)
		can_pause = false
		Core.data["current_score"] = snapped(Core.data["current_score"], 1)
		Core.data["apollo_current_score"] = snapped(Core.data["apollo_current_score"], 1)
		Core.data["artemis_current_score"] = snapped(Core.data["artemis_current_score"], 1)
		$GUI/End/Score.text = str(Core.data["current_score"])
		$GUI/End/ApolloScore.text = str(Core.data["apollo_current_score"])
		$GUI/End/ArtemisScore.text = str(Core.data["artemis_current_score"])
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
			if Core.data["current_score"] == 1000000:
				Core.sound_effect(sfx, "full-combo")
			else:
				Core.sound_effect(sfx, "end-score")
		)
	)
	
