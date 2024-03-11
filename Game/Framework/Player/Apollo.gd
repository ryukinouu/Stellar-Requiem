extends Node3D

@onready var anim_tree = $AnimationTree
@onready var anim_player = $APOLLO_Alpha_Final2/AnimationPlayer

var current_anim = "Idle"
var anim_enabled = true
var enabled = false

func animate(anim, prio):
	var state_machine = anim_tree.get("parameters/playback")
	current_anim = anim
	state_machine.travel(current_anim)
	if anim_enabled and !prio:
		return
	if prio:
		anim_enabled = false
		Core.cooldown(anim_player.get_animation(anim).length, func():
			anim_enabled = true
		)

func begin():
	animate("Walk", false)
	enabled = true

func _ready():
	anim_tree.active = true
	Core.cooldown(7, begin)
