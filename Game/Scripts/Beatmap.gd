extends Node3D

@export var BPM : float = 180
@export var length : int = 400

func _ready():
	$Visual.visible = false
	var angle_step = 2 * PI / Global.CIRCLE_MEASURES
	for note in get_children():
		if note.name == "Visual":
			continue
		var angle = note.position.x / 2 * angle_step
		var x = Global.CIRCLE_DIAMETER / 2 * cos(angle)
		var y = Global.CIRCLE_DIAMETER / 2 * sin(angle)
		note.position = Vector3(x, y, note.position.z * (1 / (BPM / 60)) * 25)
