extends Resource

class_name Song

@export var title : String = ""
@export var artist : String = ""

@export var environment : PackedScene
@export_file ("*.mid") var midi : String = ""
@export var wav : AudioStream

@export var icon : Texture2D
@export var difficulty : int = 1
@export var bpm : int = 60
@export var length : int = 100

@export var tutorial : bool = false
@export var map_speed : int = 30
@export var drum_notes : int
@export var guitar_notes : int
@export var music_first : bool = false
@export var wav_delay : float = 2.0

var channel_midi = 1
var spawn_distance = 100
var initial_delay = 4.0
