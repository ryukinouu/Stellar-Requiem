extends Node



func init_animations(anim_tree, direction, animation_state):
	anim_tree.active = true
	anim_tree.set(blend_pos(animation_state), direction)

func blend_pos(type : String):
	return "parameters/" + type + "/blend_position"
