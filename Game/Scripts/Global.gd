extends Node


func cooldown(time, exe):
	get_tree().create_timer(time).connect("timeout", exe)
