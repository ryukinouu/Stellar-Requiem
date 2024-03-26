extends Node3D

@onready var anim_tree = $AnimationTree

var current_index = 0
var songs = []

func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var contents = []
		while file_name != "":
			if file_name.ends_with(".remap"):
				file_name = file_name.replace(".remap", "")
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				contents.append(file_name)
			file_name = dir.get_next()
		return contents
	else:
		print("An error occurred when trying to access the path.")
		return null

func time_convert(time_in_sec):
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60
	return "%02d:%02d" % [minutes, seconds]

func newest_high_score(song_name):
	if DataEngine.save_info["high_scores"].has(song_name):
		$SongDescription/HighScore.text = str(DataEngine.save_info["high_scores"][song_name])
	else:
		$SongDescription/HighScore.text = "0000000"

func update_song():
	$SongDescription/SongTitle.text = songs[current_index].title.to_upper()
	$SongDescription/Artist.text = songs[current_index].artist
	$SongDescription/Info.text = "BPM: " + str(songs[current_index].bpm) + \
			" \nLENGTH: " + time_convert(songs[current_index].length)
	for diff_node in $SongDescription/Difficulty.get_children():
		if int(str(diff_node.name)) <= songs[current_index].difficulty:
			diff_node.texture = load("res://Assets/Textures/SongSelectionAssets/Asset_112x.png")
		else:
			diff_node.texture = load("res://Assets/Textures/SongSelectionAssets/Asset_142x.png")
	$SongIcon.texture = songs[current_index].icon
	$Music.stream = songs[current_index].preview
	$Music.play()
	newest_high_score(songs[current_index].title)
	$CanvasLayer/Next.modulate = Color("ffffff")
	$CanvasLayer/Previous.modulate = Color("ffffff")
	if current_index + 1 > songs.size() - 1:
		$CanvasLayer/Next.modulate = Color("ffffff82")
	if current_index - 1 < 0:
		$CanvasLayer/Previous.modulate = Color("ffffff82")

func _ready():
	var song_paths = dir_contents("res://Game/Resources/Songs/")
	
	for song_path in song_paths:
		var song_res = load("res://Game/Resources/Songs/" + song_path)
		songs.append(song_res)
	
	update_song()
	anim_tree.active = true

func _on_texture_button_pressed():
	Core.sound_effect($SFX, "button-click")
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	songs[current_index].init_scene()
	Core.cooldown(1, func():
		get_tree().change_scene_to_file(songs[current_index].environment)
	)

func _on_texture_button_2_pressed():
	Core.sound_effect($SFX, "button-click")
	var state_machine = anim_tree.get("parameters/playback")
	state_machine.travel("LoadOut")
	Core.cooldown(1, func():
		get_tree().change_scene_to_file("res://Game/Scenes/Menu/Menu.tscn")
	)

func _on_audio_toggle_toggled(toggled_on):
	$Music.stream_paused = toggled_on

func _on_audio_stream_player_finished():
	$Music.play()

func _on_previous_pressed():
	if current_index - 1 >= 0:
		Core.sound_effect($SFX, "button-click")
		current_index -= 1
		update_song()

func _on_next_pressed():
	if current_index + 1 <= songs.size() - 1:
		Core.sound_effect($SFX, "button-click")
		current_index += 1
		update_song()


func _on_start_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_back_mouse_entered():
	Core.sound_effect($SFX, "button-hover")

func _on_previous_mouse_entered():
	if current_index - 1 >= 0:
		Core.sound_effect($SFX, "button-hover")

func _on_next_mouse_entered():
	if current_index + 1 <= songs.size() - 1:
		Core.sound_effect($SFX, "button-hover")
