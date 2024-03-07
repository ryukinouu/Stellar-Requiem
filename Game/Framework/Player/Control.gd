extends Area3D

@onready var anim_tree = $AnimationTree
@onready var anim_player = $APOLLO_Alpha_Final2/AnimationPlayer

var boost_speed = 22.0
var move_speed = 8.0
var initial_speed = boost_speed

var current_anim = "Idle"
var anim_enabled = true
var enabled = false
var can_be_bombed = true
var tween

var input = {
	"left": false,
	"right": false,
	"action": false,
	"jump": false
}

var target_position : Vector3

const LIMIT_RIGHT = -14
const LIMIT_LEFT = 16

func animate(anim, prio):
	if anim_enabled and !prio:
		var state_machine = anim_tree.get("parameters/playback")
		current_anim = anim
		state_machine.travel(current_anim)
		return
	if prio:
		var state_machine = anim_tree.get("parameters/playback")
		current_anim = anim
		state_machine.travel(current_anim)
		anim_enabled = false
		Core.cooldown(anim_player.get_animation(anim).length, func():
			anim_enabled = true
		)

func begin():
	animate("Walk", false)
	enabled = true

func note_hit(hit, type):
	if type == "Hover":
		Core.data["current_score"] += Core.data["hover_note_score"]
		Core.ui_effect("add", "hover")
	elif type == "Bomb":
		if can_be_bombed:
			Core.data["player_1"]["lives"] -= 1
			can_be_bombed = false
			Core.cooldown(1, func():
				can_be_bombed = true
			)
			hit.get_node("Area3D").free()
			var anim_tree = hit.get_node("AnimationTree")
			anim_tree.active = true
			Core.cooldown(0.1,
				func():
					hit.queue_free()
			)
			return
	elif type == "Hit":
		print("HIT!")
		Core.data["current_score"] += Core.data["hit_note_score"]
		Core.ui_effect("add", "hit")
	hit.get_node("Area3D").free()
	hit.position = Vector3(0,hit.get_parent().position.y,0)
	hit.get_parent().remove_child(hit)
	$Effects.add_child(hit)
	var anim_tree = hit.get_node("AnimationTree")
	anim_tree.active = true
	Core.cooldown(0.1,
		func():
			hit.queue_free()
	)

func _input(event):
	if event.is_action_pressed("left"):
		input["left"] = true
		animate("Left", false)
	elif event.is_action_pressed("right"):
		input["right"] = true
		animate("Right", false)
	elif event.is_action_released("left"):
		input["left"] = false
		if input["right"] == false:
			animate("Walk", false)
	elif event.is_action_released("right"):
		input["right"] = false
		if input["left"] == false:
			animate("Walk", false)
	
	if event.is_action_pressed("left") or event.is_action_pressed("right"):
		if tween and tween.is_running():
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(self, "boost_speed", move_speed, 0.2).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(
			func():
				boost_speed = move_speed
		)
	elif event.is_action_released("left") or event.is_action_released("right"):
		tween.kill()
		if !input["left"] and !input["right"]:
			boost_speed = initial_speed
	
	if event.is_action_pressed("action"):
		animate("Hit", true)
		var notes = get_overlapping_areas()
		for area in notes:
			var hit = area.get_parent()
			var prefix = hit.name.substr(0, 2)
			if prefix == "Ht":
				note_hit(hit, "Hit")
	elif event.is_action_released("action"):
		pass

func _ready():
	anim_tree.active = true
	Core.cooldown(7, begin)

func _process(delta):
	if enabled:
		#print(boost_speed)
		if Input.is_action_pressed("left"):
			if position.x < 14:
				position.x = lerp(position.x, position.x + 0.1 * boost_speed, delta * move_speed)
		if Input.is_action_pressed("right"):
			if position.x > -14:
				position.x = lerp(position.x, position.x - 0.1 * boost_speed, delta * move_speed)
		
		if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
			var target_x = snapped(position.x, 2)
			position.x = lerp(position.x, float(target_x), delta * move_speed)

func _on_area_entered(area):
	var hit = area.get_parent()
	if hit.name.substr(0, 2) == "Hv":
		note_hit(hit, "Hover")
	elif hit.name.substr(0, 2) == "Ht":
		print("CAN HIT!")
	elif hit.name.substr(0, 2) == "Bm":
		note_hit(hit, "Bomb")

func _on_area_exited(area):
	var hit = area.get_parent()
	if hit.name.substr(0, 2) == "Ht":
		print("CAN'T HIT")
