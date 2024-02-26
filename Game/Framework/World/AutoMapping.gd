extends Node3D

@export var BPM : float
@export var distance : int
@export var song_length : int
@export var song_name : String

func _ready():
	$Visual.visible = false
	var counts = {
		"hover": 0,
		"hit": 0,
		"total" : 0
	}
	for note in get_children():
		if note.name == "Visual":
			continue
		elif note.name.substr(0, 7) == "Pattern":
			for subnote in note.get_children():
				handle_note(subnote, note.position, counts)
			continue
		handle_note(note, Vector3.ZERO, counts)
	var hit_weight = 3 
	counts["total"] = counts["hover"] + (counts["hit"] * hit_weight)

	var hover_ratio = float(counts["hover"]) / counts["total"]
	var hit_ratio = float((counts["hit"] * hit_weight)) / counts["total"]

	var note_points = 1000000 - (song_length * 1000)
	Core.data["hover_note_score"] = round(float(note_points * hover_ratio) / counts["hover"])
	Core.data["hit_note_score"] = round(float(note_points * hit_ratio) / counts["hit"])

func handle_note(note, offset, counts):
	if note.name.substr(0, 5) == "Hover":
		counts["hover"] += 1
		var note_scene = load("res://Game/Scenes/Notes/HoverNote.tscn")
		var note_instance = note_scene.instantiate()
		add_child(note_instance)

		note_instance.position = Vector3(
			note.position.x + offset.x, 
			note.position.y + offset.y,
			note.position.z + offset.z
		)
		note_instance.name = "Hv_Note"
		# POSITION.Z * (1 / (BPM / 60)) * (MAX DISTANCE / SONG LENGTH)
		note_instance.position.z = (note.position.z + offset.z) * (1 / (BPM / 60)) * (distance / song_length)
		note.queue_free() 
	elif note.name.substr(0, 3) == "Hit":
		counts["hit"] += 1
		var note_scene = load("res://Game/Scenes/Notes/HitNote.tscn")
		var note_instance = note_scene.instantiate()
		add_child(note_instance)

		note_instance.position = Vector3(
			note.position.x + offset.x, 
			note.position.y + offset.y,
			note.position.z + offset.z
		)
		note_instance.name = "Ht_Note"
		# POSITION.Z * (1 / (BPM / 60)) * (MAX DISTANCE / SONG LENGTH)
		note_instance.position.z = (note.position.z + offset.z) * (1 / (BPM / 60)) * (distance / song_length)
		note.queue_free() 
