extends CharacterBody3D

@export var measure : int = 12
@export var animation_state : String = "Default"

@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer

const MOVE_SPEED : float = 30.0
const EASING_FACTOR : float = 1.0

var target_position : Vector3
var target_rotation : Vector3

var has_pressed : bool
var on_cd : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	AnimationHandler.init_animations(anim_tree, animation_state)
	target_position = Vector3(
		Global.positions[measure]["position"].x, 
		Global.positions[measure]["position"].y, 
		0
	)
	target_rotation = Vector3(
		0,
		0,
		Global.positions[measure]["rotation"].z, 
	)
	position.x = target_position.x * 2
	position.y = target_position.y * 2
	rotation_degrees.z = target_rotation.z + 90

func move_direction(event):
	var direction = "none"
	if event.is_action_pressed("left"):
		measure += 1
		if measure > Global.CIRCLE_MEASURES - 1:
			measure = 0
		direction = "left"
	elif event.is_action_pressed("right"):
		measure -= 1
		if measure < 0:
			measure = Global.CIRCLE_MEASURES - 1
		direction = "right"
	
	target_position = Vector3(
		Global.positions[measure]["position"].x, 
		Global.positions[measure]["position"].y, 
		0
	)
	target_rotation = Vector3(
		0,
		0,
		Global.positions[measure]["rotation"].z, 
	)
	
	var state_machine = anim_tree.get("parameters/playback")
	if direction != "none":
		state_machine.travel(direction)
		Global.cooldown(anim_player.get_animation("left").length, 
			func(): 
				state_machine.travel("normal")
		)
	
	#anim_tree.set(AnimationHandler.blend_pos(animation_state), direction)
	
	#Global.cooldown(anim_player.get_animation("left").length, 
		#func(): 
			#direction = 0
			#anim_tree.set(AnimationHandler.blend_pos(animation_state), direction)
	#)

func _input(event):
	if event.is_action_pressed("action"):
		var state_machine = anim_tree.get("parameters/playback")
		state_machine.travel("click")
		Global.cooldown(anim_player.get_animation("click").length, 
			func(): 
				state_machine.travel("normal")
		)
	else:
		move_direction(event)

func _process(delta):
	# Move the character smoothly towards the target position
	position.x = lerp(position.x, target_position.x * 2, MOVE_SPEED * delta * EASING_FACTOR)
	position.y = lerp(position.y, target_position.y * 2, MOVE_SPEED * delta * EASING_FACTOR)
	rotation_degrees.z = lerp(rotation_degrees.z, target_rotation.z + 90, MOVE_SPEED * delta * EASING_FACTOR)
	
	#print(round(position.x) == round(target_position.x))
	
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right") and on_cd:
		has_pressed = false
