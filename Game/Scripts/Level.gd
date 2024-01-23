extends Node3D

@onready var anim_tree = $AnimationTree
@onready var circle = $Circle


func _ready():
	anim_tree.active = true
	generate_tabs_around_ring(Global.CIRCLE_MEASURES)

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

