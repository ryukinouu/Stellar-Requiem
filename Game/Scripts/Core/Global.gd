extends Node

var save_path = "user://variable.save"

const CIRCLE_DIAMETER = 8
const CIRCLE_MEASURES = 16

func cooldown(time, exe):
	get_tree().create_timer(time).connect("timeout", exe)

var positions = {}

func _ready():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		for song in game_data["high scores"]:
			game_data["high scores"][song] = file.get_var()
		file.close()
	else:
		print("No save data")
	var angle_step = 2 * PI / CIRCLE_MEASURES
	for i in range(CIRCLE_MEASURES):
		var angle = i * angle_step
		var x = (CIRCLE_DIAMETER - 0.5) / 2 * cos(angle)
		var y = (CIRCLE_DIAMETER - 0.5) / 2 * sin(angle)
		positions[i] = {}
		positions[i]["position"] = Vector3(x, y - 0.1, 0)
		positions[i]["rotation"] = Vector3(0, 0, rad_to_deg(atan2(y, x)))

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		for song in game_data["high scores"]:
			file.store_var(song)
		file.close()

var animations = {
	"normal": {
		speed = 1
	},
	"click": {
		speed = 2
	},
	"left": {
		speed = 1
	},
	"right": {
		speed = 1
	},
}

var game_data = {
	"high scores": {
		"Tutorial": 0
	}
}
