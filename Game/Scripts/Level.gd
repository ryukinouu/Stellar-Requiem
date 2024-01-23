extends Node3D

@onready var anim_tree = $AnimationTree
@onready var beatmap = $"Beat Map"
@onready var circle = $Circle


func _ready():
	anim_tree.active = true
	generate_tabs_around_ring(Global.CIRCLE_MEASURES)
	var last_z = 2.66 * 100 + 3.75
	for i in range(58):
		var note = load("res://Game/Scenes/Notes/HoverNote.tscn")
		var note_instance = note.instantiate()
		var pos = Global.positions[randi_range(0, Global.CIRCLE_MEASURES - 1)]["note_pos"]
		note_instance.position.x = pos.x
		note_instance.position.y = pos.y
		note_instance.position.z = last_z
		last_z += 1.33 * 100
		if last_z
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
