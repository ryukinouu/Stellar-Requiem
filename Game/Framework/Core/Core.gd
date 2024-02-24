extends Node


func cooldown(time, exe):
	get_tree().create_timer(time).connect("timeout", exe)

var data = {
	"current_score": 0,
	"player_1": {
		"character": "Apollo",
		"lives": 3,
	},
	"player_2": {
		"character": "Artemis",
		"lives": 3,
	}
}
