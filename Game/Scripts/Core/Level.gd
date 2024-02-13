extends Node3D

@onready var anim_tree = $AnimationTree
@onready var circle = $Circle
@onready var UI = $UI

@export var game_state = "Menu"
@export var score = 0

func _ready():
	generate_tabs_around_ring(Global.CIRCLE_MEASURES)
	UI.get_node("Menu/HighScore").text = "HIGH SCORE: " + str(Global.game_data["high scores"]["Tutorial"])
	$CanvasLayer/AnimationPlayer.play("fade_in")
	

func _process(delta):
	UI.get_node("Score/Label").text = "SCORE: " + str(score)

func generate_tabs_around_ring(number):
	var angle_step = 2 * PI / number
	for i in range(number):
		var angle = i * angle_step
		var tab_scene = load("res://Game/Scenes/Core/Tab.tscn")
		var tab_instance = tab_scene.instantiate()
		var x = Global.CIRCLE_DIAMETER / 2 * cos(angle)
		var y = Global.CIRCLE_DIAMETER / 2 * sin(angle)
		tab_instance.position = circle.position + Vector3(x, y - 0.1, 0)
		tab_instance.rotation_degrees = Vector3(0, 0, rad_to_deg(atan2(y, x)))
		circle.add_child(tab_instance)


func _on_button_button_down():
	anim_tree.active = true
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("World")
	UI.get_node("Menu").visible = false
	UI.get_node("Score").visible = true
	score = 0

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "World":
		var state_machine = anim_tree.get("parameters/playback")
		state_machine.travel("RESET")
		if score > Global.game_data["high scores"]["Tutorial"]:
			Global.game_data["high scores"]["Tutorial"] = score
		UI.get_node("Menu/HighScore").text = "HIGH SCORE: " + str(Global.game_data["high scores"]["Tutorial"])
		UI.get_node("Menu").visible = true
		UI.get_node("Score").visible = false
		get_node("Tutorial").free()
		var bm_scene = load("res://Game/Scenes/Beatmaps/Tutorial.tscn")
		var bm_instance = bm_scene.instantiate()
		add_child(bm_instance)
		bm_instance.name = "Tutorial"