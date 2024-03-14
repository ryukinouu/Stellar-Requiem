extends Node3D

@onready var midi = $Midi
@onready var music = $Main/Camera3D/Music

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

@export var map_speed : int = 30
@export var wav_delay : float = 8.0
@export var channel_midi : int = 10
@export var hit_delta : float = 0.2

var mapping = {
	36: "left",
	38: "top",
	40: "bottom",
	3: "right"
}
var ids = {"left": [], "top": [], "bottom": [], "right": []}
var canhit = {"left": [], "top": [], "bottom": [], "right": []}
var lanes = {
	"left": $Main/Notes/left, 
	"top": $Main/Notes/top, 
	"bottom": $Main/Notes/bottom, 
	"right": $Main/Notes/right
}

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
				Core.cooldown(2 - hit_delta, func():
					var note_direction = mapping[event.note]
					var note_id = ids[note_direction][-1] + 1 if ids[note_direction].size() > 0 else 1
					ids[note_direction].append(note_id)
					canhit[note_direction].append(note_id)
					print("Hit Window Start: " + note_direction + " (" + str(note_id) + ")")
					Core.cooldown(2 * hit_delta, func():
						if note_id in canhit[mapping[event.note]]:
							canhit[mapping[event.note]].erase(note_id)
							print("Hit Window End: " + mapping[event.note] + " (" + str(note_id) + ")")
					)
				)
