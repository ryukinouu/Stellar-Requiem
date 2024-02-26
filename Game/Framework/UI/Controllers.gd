extends Node3D

var apollo_base_texture: Texture = preload('res://Assets/Textures/Apollo_FullArt shaded.png')
var artemis_base_texture: Texture = preload('res://Assets/Textures/Artemis_FullArt shaded.png')
var apollo_pressed_texture: Texture = preload('res://Assets/Textures/Apollo_FullArt.png')
var artemis_pressed_texture: Texture = preload('res://Assets/Textures/Artemis_FullArt.png')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		_on_apollo_icon_pressed()
		_on_artemis_icon_pressed()

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Game/Scenes/Menu/SongSelection.tscn")

func _on_apollo_icon_pressed():
	$ApolloIcon.texture_normal = apollo_pressed_texture

func _on_artemis_icon_pressed():
	$ArtemisIcon.texture_normal = artemis_pressed_texture

func _input(event):
	if event is InputEventKey and not event.is_echo():
		if event.keycode == KEY_S:
			_on_S_key_pressed()

func _on_S_key_pressed():
	$ApolloIcon.texture_normal = apollo_base_texture
	$ArtemisIcon.texture_normal = artemis_base_texture
	
