extends Node3D

@onready var midi = $Midi
@onready var music = $Main/Camera3D/Music

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

@export var map_speed : int = 30
@export var wav_delay : float = 8.0
@export var channel_midi : int = 10
@export var hit_delta : float = 0.2

var mapping = {
	36: "left",
	38: "top",
	40: "bottom",
	3: "right"
}
var ids = {"left": [], "top": [], "bottom": [], "right": []}
var canhit = {"left": [], "top": [], "bottom": [], "right": []}

func _ready():
	var anim = anim_player.get_animation("Playing")
	var track_idx = anim.find_track("Main:position", 0)
	var key_idx = anim.track_find_key(track_idx, 600.0, true)
	anim.track_set_key_value(track_idx, key_idx, Vector3(0, 0, 600.0 * map_speed))
	anim_tree.active = true
	
	music.play()
	
