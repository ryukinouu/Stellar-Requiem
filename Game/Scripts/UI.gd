extends CanvasLayer

@onready var progress_bar = $ProgressBar

# Variables for Score
var score = 0

# Variables for progress bar
var progress = 0
var max_progress = 100
var time_to_fill = 5.0 # time in seconds to fill the progress bar


# Called when the node enters the scene tree for the first time.
func _ready():
	# Example: Update progress bar every frame
	progress_bar.value = progress
	set_process(true)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress += max_progress / time_to_fill * delta
	progress = min(progress, max_progress) # Ensure progress does not exceed max
	progress_bar.value = progress

	increase_score(1)

	
func increase_score(amount : float):
	score += amount
	update_score_display()

func update_score_display():
	$Label.text = "Score: " + str(score)


