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
@export var wav_delay : float = 2.0
@export var channel_midi : int = 1
@export var hit_delta : float = 0.2
@export var spawn_distance : int = 100

var note_scene = load("res://Game/Scenes/Notes/Note.tscn")

var mapping = {
	36: "left",
	38: "top",
	40: "bottom",
	41: "right"
}
var ids = {"left": [], "top": [], "bottom": [], "right": []}
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
	
	music.play()
	Core.cooldown(wav_delay - 2, func():
		# MIDI is 2 seconds behind
		midi.play()
	)

func _on_note_event(channel, event):
	if event.type == SMF.MIDIEventType.note_on:
		if channel.number == channel_midi - 1: 
			if event.note in mapping.keys():
				# SPAWN
				var note_direction = mapping[event.note]
				var note_instance = note_scene.instantiate()
				get_lane(note_direction).add_child(note_instance)
				note_instance.position.z = spawn_distance
				
				var tween = get_tree().create_tween()
				tween.tween_property(
					note_instance, 
					"position:z", 
					-spawn_distance / 2, 
					2 * 1.5
				)
				tween.tween_callback(note_instance.queue_free)
				
				# HIT WINDOW
				Core.cooldown(2 - hit_delta, func():
					#var note_id = ids[note_direction][-1] + 1 if ids[note_direction].size() > 0 else 1
					ids[note_direction].append(note_instance)
					canhit[note_direction].append(note_instance)
					#print("Hit Window Start: " + note_direction + " (" + str(note_id) + ")")
					Core.cooldown(2 * hit_delta, func():
						if note_instance in canhit[mapping[event.note]]:
							canhit[mapping[event.note]].erase(note_instance)
							#print("Hit Window End: " + mapping[event.note] + " (" + str(note_id) + ")")
					)
				)

func _input(event):
	if event.is_action_pressed("action-top-1"):
		if canhit["top"].size() > 0:
			print("HIT TOP!")
			var note = canhit["top"].pop_front() 
			note.get_node("AnimationTree").get("parameters/playback").travel("hit")
	elif event.is_action_pressed("action-bottom-1"):
		if canhit["bottom"].size() > 0:
			print("HIT BOTTOM!")
			var note = canhit["bottom"].pop_front()
			note.get_node("AnimationTree").get("parameters/playback").travel("hit")
	elif event.is_action_pressed("action-left-1"):
		if canhit["left"].size() > 0:
			print("HIT LEFT!")
			var note = canhit["left"].pop_front()
			note.get_node("AnimationTree").get("parameters/playback").travel("hit")
	elif event.is_action_pressed("action-right-1"): 
		if canhit["right"].size() > 0:
			print("HIT RIGHT!")
			var note = canhit["right"].pop_front()
			note.get_node("AnimationTree").get("parameters/playback").travel("hit")
