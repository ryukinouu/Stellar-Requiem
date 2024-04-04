extends Node3D

var load_in_scene = Core.scene_data["environment"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_drums_next_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Guitar1.visible = true
	$TutorialScreen/Drums.visible = false


func _on_drums_previous_pressed():
	pass # Replace with function body.


func _on_guitar_next_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Guitar2.visible = true
	$TutorialScreen/Guitar1.visible = false

	
func _on_guitar_previous_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Guitar1.visible = false
	$TutorialScreen/Drums.visible = true


func _on_guitar_2_next_pressed():
	Core.sound_effect($SFX, "button-click")
	print(load_in_scene)
	Core.cooldown(1, func():
		get_tree().change_scene_to_file(load_in_scene)
	)

func _on_guitar_2_previous_pressed():
	Core.sound_effect($SFX, "button-click")
	$TutorialScreen/Guitar2.visible = false
	$TutorialScreen/Guitar1.visible = true
#
#
#func _on_drums_next_mouse_entered():
	#Core.sound_effect($SFX, "button-hover")
	#
#
#func _on_drums_previous_mouse_entered():
	#Core.sound_effect($SFX, "button-hover")
