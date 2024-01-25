extends Node

const CIRCLE_DIAMETER = 8
const CIRCLE_MEASURES = 16

func cooldown(time, exe):
	get_tree().create_timer(time).connect("timeout", exe)

var positions = {}

func _ready():
	var angle_step = 2 * PI / CIRCLE_MEASURES
	for i in range(CIRCLE_MEASURES):
		var angle = i * angle_step
		var x = (CIRCLE_DIAMETER - 0.5) / 2 * cos(angle)
		var y = (CIRCLE_DIAMETER - 0.5) / 2 * sin(angle)
		var note_x = (CIRCLE_DIAMETER) / 2 * cos(angle)
		var note_y = (CIRCLE_DIAMETER) / 2 * sin(angle)
		positions[i] = {}
		positions[i]["position"] = Vector3(x, y - 0.1, 0)
		positions[i]["note_pos"] = Vector3(note_x, note_y - 0.1, 0)
		positions[i]["rotation"] = Vector3(0, 0, rad_to_deg(atan2(y, x)))
	print(positions)
