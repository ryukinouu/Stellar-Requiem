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

func ui_effect(type, subtype):
	if type == "add":
		if subtype == "hover":
			var additions = get_parent().get_node("/root/Level/GUI/HUD/SoloScore/Additions")
			var ui_scene = load("res://Game/Scenes/UI/AddHover.tscn")
			var ui_instance = ui_scene.instantiate()
			additions.add_child(ui_instance)
