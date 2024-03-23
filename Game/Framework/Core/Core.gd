extends Node


func cooldown(time, exe):
	get_tree().create_timer(time).connect("timeout", exe)

var data = {
	"apollo": true,
	"artemis": true,
	"d_lives": 3,
	"g_lives": 3,
	"current_score": 0,
	"keybinds": {
		"apollo-left": "A",
		"apollo-top": "S",
		"apollo-bottom": "D",
		"apollo-right": "F",
		"apollo-pause": "Escape",
		"artemis-left": "Left",
		"artemis-right": "Right",
		"artemis-action1": "H",
		"artemis-action2": "J",
		"artemis-pause": "Return",
	}
}

var scene_data = {
	"song_name": "",
	"tutorial": false,
	"map_speed": 30,
	"drum_notes": 0,
	"guitar_notes": 0,
	"music_first": false,
	"wav_delay": 2.0,
	"wav": null,
	"midi": null
}

func ui_effect(type, subtype):
	if type == "add":
		var additions = get_parent().get_node("/root/Level/GUI/HUD/SoloScore/Additions")
		if subtype == "hover":
			var ui_scene = load("res://Game/Scenes/UI/AddHover.tscn")
			var ui_instance = ui_scene.instantiate()
			ui_instance.text = "+" + str(round(data["hover_note_score"])) + "!"
			additions.add_child(ui_instance)
		elif subtype == "hit":
			var ui_scene = load("res://Game/Scenes/UI/AddHit.tscn")
			var ui_instance = ui_scene.instantiate()
			ui_instance.text = "+" + str(round(data["hit_note_score"])) + "!"
			additions.add_child(ui_instance)
