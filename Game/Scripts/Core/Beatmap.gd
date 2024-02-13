extends Node3D

@export var BPM : float = 180
@export var length : int = 400
@export var distance : int = 7

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
		elif note.name.substr(0, 10) == "ChordStart":
			var note_num = note.name.substr(11)
			var note_scene_start = load("res://Game/Scenes/Notes/ChordNoteStart.tscn")
			var note_instance_start = note_scene_start.instantiate()
			var start_angle = note.position.x / 2 * angle_step
			
			add_child(note_instance_start)
			note_instance_start.name = "Cs_Note"
			
			note.queue_free()
			note = note_instance_start
			
			var note_end = get_node("ChordEnd" + note_num)
			var note_scene_end = load("res://Game/Scenes/Notes/ChordNoteEnd.tscn")
			var note_instance_end = note_scene_end.instantiate()
			
			add_child(note_instance_end)
			note_instance_end.position = calc_dist(note_end, angle_step)
			note_instance_end.name = "Ce_Note"
			
			var mid_length = (note_instance_end.position.z - note_instance_start.position.z) / 1.5
			var mid_x = (distance + Global.CIRCLE_DIAMETER) / 2 * cos(start_angle)
			var mid_y = (distance + Global.CIRCLE_DIAMETER) / 2 * sin(start_angle)
			
			var mid_position = Vector3(mid_x, mid_y, (note_instance_start.position.z + note_instance_end.position.z) / 2)
			var note_scene_middle = load("res://Game/Scenes/Notes/ChordNoteMiddle.tscn")
			var note_instance_middle = note_scene_middle.instantiate()
			
			add_child(note_instance_middle)
			note_end.queue_free()
			
			note_instance_middle.mesh.height = mid_length
			note_instance_middle.get_node("Area3D/CollisionShape3D").shape.size = Vector3(1, mid_length, 1)
			note_instance_middle.get_node("Area3D/CollisionShape3D/Visualizer").mesh.size = Vector3(1, mid_length, 1)
			note_instance_middle.position = mid_position
			note_instance_middle.name = "Cm_Note"
		
		calc_dist(note, angle_step)

func calc_dist(note, angle_step):
	var angle = note.position.x / 2 * angle_step
	var x = (distance + Global.CIRCLE_DIAMETER) / 2 * cos(angle)
	var y = (distance + Global.CIRCLE_DIAMETER) / 2 * sin(angle)
	note.position = Vector3(x, y, note.position.z * (1 / (BPM / 60)) * 25)
