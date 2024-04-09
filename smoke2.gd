extends CPUParticles3D


@onready var timecreated = Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() - timecreated > 10000:
		queue_free()
	await get_tree().create_timer(1).timeout
	explosiveness = 0.35
	pass
