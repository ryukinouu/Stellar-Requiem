extends Node3D

@onready var anim_tree = $AnimationTree
@onready var beatmap = $"Beat Map"
@onready var circle = $Circle


func _ready():
	anim_tree.active = true
	generate_tabs_around_ring(Global.CIRCLE_MEASURES)
	var last_z = 2.66 * 100 + 3.75
	for i in range(3):
		var note = load("res://Game/Scenes/Notes/HoverNote.tscn")
		var note_instance = note.instantiate()
		var pos = Global.positions[randi_range(0, Global.CIRCLE_MEASURES - 1)]["note_pos"]
		note_instance.position.x = pos.x
		note_instance.position.y = pos.y
		note_instance.position.z = last_z
		last_z += 2.66 * 100
		beatmap.add_child(note_instance)
	var last_tick = 0
	var min_tick = 0
	var max_tick = Global.CIRCLE_MEASURES - 1
	for i in range(54):
		var note = load("res://Game/Scenes/Notes/HoverNote.tscn")
		var note_instance = note.instantiate()
		if last_tick == 0:
			min_tick = 10
			max_tick = 2
		elif last_tick == 1:
			min_tick = 11
			max_tick = 3
		elif last_tick == 11:
			min_tick = 9
			max_tick = 1
		elif last_tick == 10:
			min_tick = 8
			max_tick = 0
		else:
			min_tick = last_tick - 2
			max_tick = last_tick + 2
		var chosen_tick = randi_range(min_tick, max_tick)
		var pos = Global.positions[chosen_tick]["note_pos"]
		note_instance.position.x = pos.x
		note_instance.position.y = pos.y
		note_instance.position.z = last_z
		last_z += 0.16625 * 100
		last_tick = chosen_tick
		beatmap.add_child(note_instance)

func generate_tabs_around_ring(number):
	var angle_step = 2 * PI / number
	for i in range(number):
		var angle = i * angle_step
		var tab_scene = load("res://Game/Scenes/Tab.tscn")
		var tab_instance = tab_scene.instantiate()
		var x = Global.CIRCLE_DIAMETER / 2 * cos(angle)
		var y = Global.CIRCLE_DIAMETER / 2 * sin(angle)
		tab_instance.position = circle.position + Vector3(x, y - 0.1, 0)
		tab_instance.rotation_degrees = Vector3(0, 0, rad_to_deg(atan2(y, x)))
		circle.add_child(tab_instance)
