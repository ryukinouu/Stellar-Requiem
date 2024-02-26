extends Node

var save_path = "user://save.dat"
var save_info = {
	"songs": {
		"Meow": {
			"high_score": 0,
		},
		"Music Box": {
			"high_score": 0
		}
	}
}

func save_data():
	var save = FileAccess.open(save_path, FileAccess.WRITE)
	save.store_var(save_info)

func load_data():
	if FileAccess.file_exists(save_path):
		var save = FileAccess.open(save_path, FileAccess.READ)
		var data = save.get_var()
	else:
		save_data()

func _ready():
	load_data()

