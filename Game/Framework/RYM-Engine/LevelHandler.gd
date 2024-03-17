extends Node3D

@onready var midi = $Midi
@onready var music = $Main/Camera3D/Music

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

@onready var lane_left = $Main/Notes/left
@onready var lane_top = $Main/Notes/top
@onready var lane_bottom = $Main/Notes/bottom
@onready var lane_right = $Main/Notes/right

@export var map_speed : int = 30
@export var channel_midi : int = 1
@export var spawn_distance : int = 100

@export var wav_delay : float = 6.0
@export var music_first : bool = false

var delta_stellar = 0.05
var delta_great = 0.05
var delta_good = 0.05
var delta_bad = 0.05
var delta_miss = 0.1
var hit_delta = delta_stellar + delta_great + delta_good + delta_bad + delta_miss

var note_scene = load("res://Game/Scenes/Notes/Note.tscn")
var miss_texture = load("res://Assets/Textures/Indicators/MISS.png")
var great_texture = load("res://Assets/Textures/Indicators/GREAT!.png")
var good_texture = load("res://Assets/Textures/Indicators/GOOD!.png")
var bad_texture = load("res://Assets/Textures/Indicators/BAD.png")
var stellar_texture = load("res://Assets/Textures/Indicators/STELLAR!.png")

var mapping = {
	36: "left",
	38: "top",
	40: "bottom",
	41: "right"
}
var tweens = {}
var canhit = {"left": [], "top": [], "bottom": [], "right": []}

func get_lane(direction):
	if direction == "left":
		return lane_left
	elif direction == "top":
		return lane_top
	elif direction == "bottom":
		return lane_bottom
	elif direction == "right":
		return lane_right

func _ready():
	var anim = anim_player.get_animation("Playing")
	var track_idx = anim.find_track("Main:position", 0)
	var key_idx = anim.track_find_key(track_idx, 600.0, true)
	anim.track_set_key_value(track_idx, key_idx, Vector3(0, 0, 600.0 * map_speed))
	anim_tree.active = true
	
	if music_first:
		Core.cooldown(2, func():
			music.play()
			Core.cooldown(wav_delay - 2, func():
				midi.play()
			)
		)
	else:
		Core.cooldown(2, func():
			midi.play()
			Core.cooldown(2, func():
				music.play()
			)
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
					Core.cooldown(hit_delta, func():
						if note_instance in canhit[mapping[event.note]]:
							canhit[mapping[event.note]].erase(note_instance)
							tweens.erase(note_instance)
					)
				)
				
				Core.cooldown(2 - hit_delta, func():
					note_instance.get_node("Miss").name = "Miss"
					Core.cooldown(delta_miss, func():
						note_instance.get_node("Miss").name = "Bad"
						Core.cooldown(delta_bad, func():
							note_instance.get_node("Bad").name = "Good"
							Core.cooldown(delta_good, func():
								note_instance.get_node("Good").name = "Great"
								Core.cooldown(delta_great, func():
									note_instance.get_node("Great").name = "Stellar"
									Core.cooldown(delta_stellar, func():
										note_instance.get_node("Stellar").name = "Miss"
									)
								)
							)
						)
					)
				)

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

func _input(event):
	if event.is_action_pressed("action-top-1"):
		if canhit["top"].size() > 0:
			var note = canhit["top"].pop_front()
			note_on_hit(note)
	elif event.is_action_pressed("action-bottom-1"):
		if canhit["bottom"].size() > 0:
			var note = canhit["bottom"].pop_front()
			note_on_hit(note)
	elif event.is_action_pressed("action-left-1"):
		if canhit["left"].size() > 0:
			var note = canhit["left"].pop_front()
			note_on_hit(note)
	elif event.is_action_pressed("action-right-1"): 
		if canhit["right"].size() > 0:
			var note = canhit["right"].pop_front()
			note_on_hit(note)
