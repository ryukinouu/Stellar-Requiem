extends Node3D

var BPM: float = 120 # Example BPM
var distance: int = 1000 # Example max distance
var song_length: int = 180 # Example song length in seconds

@onready var onhit_midi = $MidiPlayer
@onready var prep_midi = $MidiPlayer2

var channel_midi = 10
var delta = 0.05
var mapping = {
	36: "top",
	38: "bottom"
}
var canhit = {
	"left": null,
	"top": null,
	"bottom": null,
	"right": null
}

func _ready():
	print(onhit_midi.get_)
	prep_midi.play()
	Core.cooldown(2, func():
		onhit_midi.play()
	)

func map_hit_note(note, velocity, midi_time):
	var z_pos = calculate_position(midi_time)
	var note_instance = preload("res://Game/Scenes/Notes/HitNote.tscn").instantiate()
	note_instance.position = Vector3(0, 0, z_pos)
	add_child(note_instance)

func calculate_position(midi_time):
	var time_in_seconds = midi_time_to_seconds(midi_time)
	return time_in_seconds * (1 / (BPM / 60)) * (distance / song_length)

func midi_time_to_seconds(midi_time):
	var timebase = onhit_midi.smf_data.timebase
	var seconds_per_tick = (60.0 / (BPM * timebase))
	return midi_time * seconds_per_tick

func _on_midi_player_midi_event(channel, event):
	if event.type == SMF.MIDIEventType.note_on:
		if channel.number == channel_midi - 1: 
			if event.note in mapping.keys():
				Core.cooldown(delta, func():
					if canhit[mapping[event.note]] != event.note:
						canhit[mapping[event.note]] = null
				)

func _on_midi_player_2_midi_event(channel, event):
	if event.type == SMF.MIDIEventType.note_on:
		if channel.number == channel_midi - 1: 
			if event.note in mapping.keys():
				Core.cooldown(2 - delta, func():
					canhit[mapping[event.note]] = event.note
					print("HIT NOW!")
				)

func _input(event):
	if event.is_action_pressed("action-top-1"):
		if canhit["top"] != null:
			print("HIT TOP!")
			canhit["top"] = null
	elif event.is_action_pressed("action-bottom-1"):
		if canhit["bottom"] != null:
			print("HIT BOTTOM!")
			canhit["bottom"] = null
