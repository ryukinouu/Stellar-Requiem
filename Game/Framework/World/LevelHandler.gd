extends Node3D

@export var map_speed = 10

@onready var midi = $Midi
@onready var music_player = $Main/Camera3D/Music

@onready var anim_player = $AnimationPlayer

func _ready():
	var anim = anim_player.get_animation("Playing")
	var track_idx = anim.find_track("Main:position:z", 0)
	var key_idx = anim.track_find_key(track_idx, 600.0, true)
	print(key_idx)
	anim.track_set_key_value(track_idx, key_idx, 600.0 * map_speed)
