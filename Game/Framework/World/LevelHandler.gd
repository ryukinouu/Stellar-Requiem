extends Node3D

@export var map_speed : int = 10
@export var wav_delay : float = 8.0

@onready var midi = $Midi
@onready var music = $Main/Camera3D/Music

@onready var anim_player = $AnimationPlayer

func _ready():
	var anim = anim_player.get_animation("Playing")
	var track_idx = anim.find_track("Main:position:z", 0)
	var key_idx = anim.track_find_key(track_idx, 600.0, true)
	anim.track_set_key_value(track_idx, key_idx, 600.0 * map_speed)
	print(key_idx)
	print(track_idx)
	music.play()
