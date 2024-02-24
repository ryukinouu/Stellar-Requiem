extends Area3D

@onready var anim_tree = $AnimationTree

var boost_speed = 12.0
var move_speed = 8.0
var initial_speed = boost_speed

var current_anim = "Idle"
var enabled = false
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

func begin():
	var state_machine = anim_tree.get("parameters/playback")
	current_anim = "Walk"
	state_machine.travel(current_anim)
	enabled = true

func note_hit(hit, type):
	if type == "Hover":
		Core.data["current_score"] += 100
		Core.ui_effect("add", "hover")
	hit.get_node("Area3D").free()
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
	elif event.is_action_pressed("right"):
		input["right"] = true
	elif event.is_action_released("left"):
		input["left"] = false
	elif event.is_action_released("right"):
		input["right"] = false
	
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
		pass
	elif event.is_action_released("action"):
		pass

func _ready():
	anim_tree.active = true
	Core.cooldown(7, begin)

func _process(delta):
	if enabled:
		#print(boost_speed)
		if Input.is_action_pressed("left"):
			position.x = lerp(position.x, position.x + 0.1 * boost_speed, delta * move_speed)
		if Input.is_action_pressed("right"):
			position.x = lerp(position.x, position.x - 0.1 * boost_speed, delta * move_speed)

func _on_area_entered(area):
	var hit = area.get_parent()
	if hit.name.substr(0, 2) == "Hv":
		note_hit(hit, "Hover")

func _on_area_exited(area):
	pass
