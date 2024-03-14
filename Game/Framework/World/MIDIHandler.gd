extends Node3D

var BPM: float = 120
var distance: int = 1000
var song_length: int = 180
var wav_delay : int = 8

@onready var prep_midi = $MidiPlayer2
@onready var music_player = $MusicPlayer

var channel_midi = 10
var delta = 0.2
var mapping = {
	1: "left",
	3: "top",
	40: "bottom",
	2: "right"
}
var ids ={
	"left": [],
	"top": [],
	"bottom": [],
	"right": []
}
var canhit = {
	"left": [],
	"top": [],
	"bottom": [],
	"right": []
}

func _ready():
	music_player.play()
	Core.cooldown(wav_delay - 2, func():
		prep_midi.play()
	)

#func _on_midi_player_midi_event(channel, event):
	#if event.type == SMF.MIDIEventType.note_on:
		#if channel.number == channel_midi - 1: 
			#if event.note in mapping.keys():
				#var note_id = ids[mapping[event.note]].pop(0) if ids[mapping[event.note]] else 0
				#Core.cooldown(2 * delta, func():
					#if note_id in canhit[mapping[event.note]]:
						#canhit[mapping[event.note]].erase(note_id)
						#print("Hit Window End: " + mapping[event.note] + " (" + str(note_id) + ")")
				#)

func _on_midi_player_2_midi_event(channel, event):
	if event.type == SMF.MIDIEventType.note_on:
		if channel.number == channel_midi - 1: 
			if event.note in mapping.keys():
				Core.cooldown(2 - delta, func():
					var note_direction = mapping[event.note]
					var note_id = ids[note_direction][-1] + 1 if ids[note_direction].size() > 0 else 1
					ids[note_direction].append(note_id)
					canhit[note_direction].append(note_id)
					print("Hit Window Start: " + note_direction + " (" + str(note_id) + ")")
					Core.cooldown(2 * delta, func():
						if note_id in canhit[mapping[event.note]]:
							canhit[mapping[event.note]].erase(note_id)
							print("Hit Window End: " + mapping[event.note] + " (" + str(note_id) + ")")
					)
				)

func _input(event):
	if event.is_action_pressed("action-top-1"):
		if canhit["top"].size() > 0:
			print("HIT TOP!")
			canhit["top"].pop_front() 
	elif event.is_action_pressed("action-bottom-1"):
		if canhit["bottom"].size() > 0:
			print("HIT BOTTOM!")
			canhit["bottom"].pop_front()
	elif event.is_action_pressed("action-left-1"):
		if canhit["left"].size() > 0:
			print("HIT LEFT!")
			canhit["left"].pop_front()
	elif event.is_action_pressed("action-right-1"): 
		if canhit["right"].size() > 0:
			print("HIT RIGHT!")
			canhit["right"].pop_front()
