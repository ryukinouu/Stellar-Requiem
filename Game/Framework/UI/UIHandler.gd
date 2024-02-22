extends CanvasLayer


func _ready():
	$HUD/AnimationPlayer.active = true

func _process(delta):
	var progress_ratio = $HUD/Score/Bar.value / $HUD/Score/Bar.max_value
	$HUD/Score/Glow.position.x = -1498 + $HUD/Score/Bar.size.x * progress_ratio
