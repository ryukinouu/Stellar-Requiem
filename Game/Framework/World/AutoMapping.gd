extends Node3D

@export var BPM : float
@export var distance : int
@export var song_length : int

func _ready():
	$Visual.visible = false
	for note in get_children():
		if note.name == "Visual":
			continue
		elif note.name.substr(0, 7) == "Pattern":
			for subnote in note.get_children():
				handle_note(subnote, note.position)
			continue
		handle_note(note, Vector3.ZERO)

func handle_note(note, offset):
	if note.name.substr(0, 5) == "Hover":
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
