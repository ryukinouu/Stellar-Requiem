extends Node3D

@export var BPM : float = 180
@export var length : int = 400

func make_mesh_local(mesh_instance):
	var local_mesh = mesh_instance.duplicate()
	mesh_instance.mesh = local_mesh

func _ready():
	$Visual.visible = false
	var angle_step = 2 * PI / Global.CIRCLE_MEASURES
	for note in get_children():
		if note.name == "Visual":
			continue
		
		if note.name.substr(0, 5) == "Hover":
			var note_scene = load("res://Game/Scenes/Notes/HoverNote.tscn")
			var note_instance = note_scene.instantiate()
			add_child(note_instance)

			note_instance.position = note.position
			note_instance.name = "Hv_Note"
			note.queue_free()
			note = note_instance
		elif note.name.substr(0, 4) == "Bomb":
			var note_scene = load("res://Game/Scenes/Notes/BombNote.tscn")
			var note_instance = note_scene.instantiate()
			add_child(note_instance)

			note_instance.position = note.position
			note_instance.name = "Bm_Note"
			note.queue_free()
			note = note_instance
		elif note.name.substr(0, 3) == "Hit":
			var note_scene = load("res://Game/Scenes/Notes/HitNote.tscn")
			var note_instance = note_scene.instantiate()
			add_child(note_instance)

			note_instance.position = note.position
			note_instance.name = "Ht_Note"
			note.queue_free()
			note = note_instance
		
		var angle = note.position.x / 2 * angle_step
		var distance = 7
		var x = (distance + Global.CIRCLE_DIAMETER) / 2 * cos(angle)
		var y = (distance + Global.CIRCLE_DIAMETER) / 2 * sin(angle)
		note.position = Vector3(x, y, note.position.z * (1 / (BPM / 60)) * 25)
