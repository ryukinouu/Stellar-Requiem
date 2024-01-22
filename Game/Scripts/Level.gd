extends Node3D

@onready var anim_tree = $AnimationTree
@onready var circle = $Circle

var number_of_tabs = 10

func _ready():
	anim_tree.active = true
	generate_tabs_around_ring(number_of_tabs)

func generate_tabs_around_ring(number):
	var angle_step = 2 * PI / number
	for i in range(number):
		var angle = i * angle_step
		var tab_scene = load("res://Game/Scenes/Tab.tscn")
		var tab_instance = tab_scene.instantiate()
		var x = 4 * cos(angle)
		var z = 4 * sin(angle)
		tab_instance.position = circle.position + Vector3(x, z, 0)
		tab_instance.rotation_degrees = Vector3(0, 0, rad_to_deg(atan2(z, x)))
		circle.add_child(tab_instance)

