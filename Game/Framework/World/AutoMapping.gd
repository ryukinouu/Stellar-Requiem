extends Node3D

@export var BPM : float = 85

func _ready():
	$Visual.visible = false
	for note in get_children():
		if note.name == "Visual":
			continue
		
		if note.name.substr(0, 5) == "Hover":
			var note_scene = load("res://Game/Scenes/Notes/HoverNote.tscn")
			var note_instance = note_scene.instantiate()
			add_child(note_instance)

			note_instance.position = note.position
			note_instance.name = "Hv_Note"
			note_instance.position.z = note.position.z * (1 / (BPM / 60)) * 12
			note.queue_free() 
