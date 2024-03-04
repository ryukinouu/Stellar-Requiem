extends Node


func cooldown(time, exe):
	get_tree().create_timer(time).connect("timeout", exe)

var data = {
	"multiplayer": false,
	"current_score": 0,
	"hover_note_score": 0,
	"hit_note_score": 0,
	"player_1": {
		"character": "Apollo",
		"lives": 3,
	},
	"player_2": {
		"character": "Artemis",
		"lives": 3,
	},
	"keybinds": {
		"left": "A",
		"right": "D",
		"action": "S",
		"escape": "escape"
	}
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
