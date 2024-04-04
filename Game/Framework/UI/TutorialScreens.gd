extends Node3D

var load_in_scene = Core.scene_data["environment"]
@onready var anim_tree = $AnimationTree

func _ready():
	anim_tree.active = true

func _on_drums_next_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Pictures/Guitar1.visible = true
	$TutorialScreen/Buttons/Guitar1.visible = true
	$TutorialScreen/Pictures/Drums.visible = false
	$TutorialScreen/Buttons/Drums.visible = false


func _on_drums_previous_pressed():
	pass # Replace with function body.

func _on_guitar_next_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Pictures/Guitar2.visible = true
	$TutorialScreen/Pictures/Guitar1.visible = false
	$TutorialScreen/Buttons/Guitar2.visible = true
	$TutorialScreen/Buttons/Guitar1.visible = false

	
func _on_guitar_previous_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Pictures/Guitar1.visible = false
	$TutorialScreen/Pictures/Drums.visible = true
	$TutorialScreen/Buttons/Guitar1.visible = false
	$TutorialScreen/Buttons/Drums.visible = true


func _on_guitar_2_next_pressed():
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.sound_effect($SFX, "button-click")
	Core.cooldown(1, func():
		get_tree().change_scene_to_file(load_in_scene)
	)

func _on_guitar_2_previous_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Pictures/Guitar2.visible = false
	$TutorialScreen/Pictures/Guitar1.visible = true
	$TutorialScreen/Buttons/Guitar2.visible = false
	$TutorialScreen/Buttons/Guitar1.visible = true
#
#
#func _on_drums_next_mouse_entered():
	#Core.sound_effect($SFX, "button-hover")
	#
#
#func _on_drums_previous_mouse_entered():
	#Core.sound_effect($SFX, "button-hover")
