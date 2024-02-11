extends Area3D

@export var measure : int = 12
@export var animation_state : String = "Default"

@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var effects = $Effects

const MOVE_SPEED : float = 30.0
const EASING_FACTOR : float = 1.0

var target_position : Vector3
var target_rotation : Vector3
var current_anim = "normal"

var has_pressed: bool = false
var on_cd: bool = false

var chord_active: bool = false
var chord_start_time = 0.0
var chord_end_time = 0.0
var chord_note_id: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.active = true
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
	
	if direction != "none":
		animate(direction, "normal")
	
	#anim_tree.set("parameters/" + animation_state + "/blend_position", direction)
	
	#Global.cooldown(anim_player.get_animation("left").length, 
		#func(): 
			#direction = 0
			#anim_tree.set(parameters/" + animation_state + "/blend_position", direction)
	#)

func animate(animation, next):
	var state_machine = anim_tree.get("parameters/playback")
	current_anim = animation
	state_machine.travel(animation)
	Global.cooldown(anim_player.get_animation(animation).length / Global.animations[animation].speed,
		func(): 
			current_anim = next
			state_machine.travel(next)
	)

func note_hit(hit, type):
	if type == "Bomb":
		get_parent().score -= 100
	elif type == "Chord":
		var time_held = ceil(chord_end_time - chord_start_time / 1000)
		get_parent().score += 10 * time_held
	else:
		get_parent().score += 100
	hit.get_node("Area3D").free()
	hit.get_parent().remove_child(hit)
	effects.add_child(hit)
	var anim_tree = hit.get_node("AnimationTree")
	anim_tree.active = true
	Global.cooldown(0.1,
		func():
			hit.queue_free()
	)

func _input(event):
	if event.is_action_pressed("action"):
		animate("click", "normal")
		has_pressed = true
		var notes = get_overlapping_areas()
		for area in notes:
			var hit = area.get_parent()
			var prefix = hit.name.substr(0, 2)
			
			if prefix == "Cs":
				print("Found Start")
				chord_active = true
				chord_note_id = hit.name.substr(3)
				chord_start_time = Time.get_ticks_msec()
			elif prefix == "Cm":
				print("Found Middle")
				if !chord_active:
					chord_active = true
					chord_note_id = hit.name.substr(3)
					chord_start_time = Time.get_ticks_msec()
				elif chord_active and chord_note_id == hit.name.substr(3):
					pass
				else:
					print("Error! Chord is active but current Chord ID is different.")
			elif prefix == "Ce":
				print("Found End")
				if !chord_active:
					pass
				elif chord_active and chord_note_id == hit.name.substr(3):
					chord_active = false
					chord_note_id = ""
					chord_end_time = Time.get_ticks_msec()
					note_hit(hit, "Chord")
				else:
					print("Error! Chord is active but current Chord ID is different.")
			elif prefix == "Ht":
				note_hit(hit, "Hit")
	
	if event.is_action_released("action"):
		has_pressed = false
		var notes = get_overlapping_areas()
		for area in notes:
			var hit = area.get_parent()
			var prefix = hit.name.substr(0, 2)
			
			if prefix == "Cs" or prefix == "Cm" or prefix == "Ce":
				if !chord_active:
					pass
				elif chord_active and chord_note_id == hit.name.substr(3):
					chord_active = false
					chord_note_id = ""
					chord_end_time = Time.get_ticks_msec()
					note_hit(hit, "Chord")
				else:
					print("Error! Chord is active but current Chord ID is different.")
			else:
				pass
	else:
		move_direction(event)

func _process(delta):
	anim_tree.advance(delta * Global.animations[current_anim].speed)
	
	# Move the character smoothly towards the target position
	position.x = lerp(position.x, target_position.x * 2, MOVE_SPEED * delta * EASING_FACTOR)
	position.y = lerp(position.y, target_position.y * 2, MOVE_SPEED * delta * EASING_FACTOR)
	rotation_degrees.z = lerp(rotation_degrees.z, target_rotation.z + 90, MOVE_SPEED * delta * EASING_FACTOR)
	
	#print(round(position.x) == round(target_position.x))
	
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right") and on_cd:
		has_pressed = false

func _on_area_entered(area):
	var hit = area.get_parent()
	if hit.name.substr(0, 2) == "Hv":
		note_hit(hit, "Hover")
	elif hit.name.substr(0, 2) == "Bm":
		note_hit(hit, "Bomb")
	elif hit.name.substr(0, 2) == "Ht":
		print("CAN HIT: " + hit.name)

func _on_area_exited(area):
	var hit = area.get_parent()
	if hit.name.substr(0, 2) == "Ht" or hit.name.substr(0, 1) == "C":
		print("CAN'T HIT: " + hit.name)
