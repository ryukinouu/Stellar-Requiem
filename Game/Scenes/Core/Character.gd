extends Area3D

@onready var anim_tree = $AnimationTree

var current_anim = "Idle"

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.active = true
	Global.cooldown(6,
			func(): 
				var state_machine = anim_tree.get("parameters/playback")
				current_anim = "Walk"
				state_machine.travel(current_anim)
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	pass # Replace with function body.

func _on_area_exited(area):
	pass # Replace with function body.
