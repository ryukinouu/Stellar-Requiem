extends CharacterBody3D

@export var measure : int = 0
@export var direction : int = 0
@export var animation_state : String = "Default"

@onready var anim_tree = $AnimationTree

const MAX_MEASURES : int = 7
const MOVE_SPEED : float = 10.0
const EASING_FACTOR : float = 5.0

var target_position : Vector3
var has_pressed : bool
var on_cd : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	AnimationHandler.init_animations(anim_tree, direction, animation_state)

func _input(event):
	print(measure)
	if event.is_action_pressed("left"):
		if measure < MAX_MEASURES:
			measure += 1
			direction = -1
	elif event.is_action_pressed("right"):
		if measure > -MAX_MEASURES:
			measure -= 1
			direction = 1
	
	target_position = Vector3(measure, 0, 0)
	anim_tree.set(AnimationHandler.blend_pos(animation_state), direction)
	
	has_pressed = true
	on_cd = true
	Global.cooldown(0.1, 
		func(): 
			on_cd = false
			if has_pressed == false:
				direction = 0
				anim_tree.set(AnimationHandler.blend_pos(animation_state), direction)
	)

func _process(delta):
	# Move the character smoothly towards the target position
	position.x = lerp(position.x, target_position.x * 2, MOVE_SPEED * delta * EASING_FACTOR)
	
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right") and on_cd:
		has_pressed = false
